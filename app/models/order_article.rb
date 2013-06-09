# An OrderArticle represents a single Article that is part of an Order.
class OrderArticle < ActiveRecord::Base

  attr_reader :update_current_price

  belongs_to :order
  belongs_to :article
  belongs_to :article_price
  has_many :group_order_articles, :dependent => :destroy

  validates_presence_of :order_id, :article_id
  validate :article_and_price_exist
  validates_uniqueness_of :article_id, scope: :order_id

  scope :ordered, :conditions => "units_to_order >= 1"

  before_create :init_from_balancing
  after_destroy :update_ordergroup_prices

  def self.sort_by_name(order_articles)
    order_articles.sort { |a,b| a.article.name <=> b.article.name }
  end

  def self.sort_by_order_number(order_articles)
    order_articles.sort do |a,b|
      a.article.order_number.to_s.gsub(/[^[:digit:]]/, "").to_i <=>
          b.article.order_number.to_s.gsub(/[^[:digit:]]/, "").to_i
    end
  end

  # This method returns either the ArticlePrice or the Article
  # The first will be set, when the the order is finished
  def price
    article_price || article
  end
  
  # Count quantities of belonging group_orders. 
  # In balancing this can differ from ordered (by supplier) quantity for this article.
  def group_orders_sum
    quantity = group_order_articles.collect(&:result).sum
    {:quantity => quantity, :price => quantity * price.fc_price}
  end

  # Update quantity/tolerance/units_to_order from group_order_articles
  def update_results!
    if order.open?
      quantity = group_order_articles.collect(&:quantity).sum
      tolerance = group_order_articles.collect(&:tolerance).sum
      update_attributes(:quantity => quantity, :tolerance => tolerance,
                        :units_to_order => calculate_units_to_order(quantity, tolerance))
    elsif order.finished?
      update_attribute(:units_to_order, group_order_articles.collect(&:result).sum)
    end
  end

  # Returns how many units of the belonging article need to be ordered given the specified order quantity and tolerance.
  # This is determined by calculating how many units can be ordered from the given order quantity, using
  # the tolerance to order an additional unit if the order quantity is not quiet sufficient.
  # There must always be at least one item in a unit that is an ordered quantity (no units are ever entirely
  # filled by tolerance items only).
  #
  # Example:
  #
  # unit_quantity | quantity | tolerance | calculate_units_to_order
  # --------------+----------+-----------+-----------------------
  #      4        |    0     |     2     |           0
  #      4        |    0     |     5     |           0
  #      4        |    2     |     2     |           1
  #      4        |    4     |     2     |           1
  #      4        |    4     |     4     |           1
  #      4        |    5     |     3     |           2
  #      4        |    5     |     4     |           2
  #
  def calculate_units_to_order(quantity, tolerance = 0)
    unit_size = price.unit_quantity
    units = quantity / unit_size
    remainder = quantity % unit_size
    units += ((remainder > 0) && (remainder + tolerance >= unit_size) ? 1 : 0)
  end

  # Calculate price for ordered quantity.
  def total_price
    units_to_order * price.unit_quantity * price.price
  end

  # Calculate gross price for ordered qunatity.
  def total_gross_price
    units_to_order * price.unit_quantity * price.gross_price
  end

  def ordered_quantities_equal_to_group_orders?
    (units_to_order * price.unit_quantity) == group_orders_sum[:quantity]
  end

  # Updates order_article and belongings during balancing process
  def update_article_and_price!(order_article_attributes, article_attributes, price_attributes = nil)
    OrderArticle.transaction do
      # Updates self
      self.update_attributes!(order_article_attributes)

      # Updates article
      article.update_attributes!(article_attributes)

      # Updates article_price belonging to current order article
      if price_attributes.present?
        article_price.attributes = price_attributes
        if article_price.changed?
          # Updates also price attributes of article if update_current_price is selected
          if update_current_price
            article.update_attributes!(price_attributes)
            self.article_price = article.article_prices.first # Assign new created article price to order article
          else
            # Creates a new article_price if neccessary
            # Set created_at timestamp to order ends, to make sure the current article price isn't changed
            create_article_price!(price_attributes.merge(created_at: order.ends)) and save
          end

          # Updates ordergroup values
          update_ordergroup_prices
        end
      end
    end
  end

  def update_current_price=(value)
    @update_current_price = (value == true or value == '1') ?  true : false
  end

  # Units missing for the next full unit_quantity of the article
  def missing_units
    units = article.unit_quantity - ((quantity  % article.unit_quantity) + tolerance)
    units = 0 if units < 0
    units
  end

  private
  
  def article_and_price_exist
     errors.add(:article, "muss angegeben sein und einen aktuellen Preis haben") if !(article = Article.find(article_id)) || article.fc_price.nil?
  end

  # Associate with current article price if created in a finished order
  def init_from_balancing
    if order.present? and order.finished?
      self.article_price = article.article_prices.first
      self.units_to_order = 1
    end
  end

  def update_ordergroup_prices
    # updates prices of ALL ordergroups - these are actually too many
    # in case of performance issues, update only ordergroups, which ordered this article
    # CAUTION: in after_destroy callback related records (e.g. group_order_articles) are already non-existent
    order.group_orders.each { |go| go.update_price! }
  end

end

