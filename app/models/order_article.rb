# An OrderArticle represents a single Article that is part of an Order.
class OrderArticle < ActiveRecord::Base

  belongs_to :order
  belongs_to :article
  belongs_to :article_price
  has_many :group_order_articles, :dependent => :destroy

  validates_presence_of :order_id, :article_id
  validate :article_and_price_exist

  named_scope :ordered, :conditions => "units_to_order >= 1"


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
  def update_article_and_price!(article_attributes, price_attributes, order_article_attributes, global_attribute)
    OrderArticle.transaction do
      # Updates article
      article.update_attributes!(article_attributes)
      article.update_attributes!(price_attributes) if global_attribute


      article_price.attributes = price_attributes
      if article_price.changed?
        # Creates a new article_price if neccessary
        price = build_article_price(price_attributes)
        price.created_at = order.ends
        price.save!

        # Updates ordergroup values
        group_order_articles.each { |goa| goa.group_order.update_price! }
      end
      

      # Updates units_to_order
      self.attributes = order_article_attributes
      self.save!
    end
  end

  private
  
  def article_and_price_exist
     errors.add(:article, "muss angegeben sein und einen aktuellen Preis haben") if !(article = Article.find(article_id)) || article.fc_price.nil?
  end

end

# == Schema Information
#
# Table name: order_articles
#
#  id               :integer(4)      not null, primary key
#  order_id         :integer(4)      default(0), not null
#  article_id       :integer(4)      default(0), not null
#  quantity         :integer(4)      default(0), not null
#  tolerance        :integer(4)      default(0), not null
#  units_to_order   :integer(4)      default(0), not null
#  lock_version     :integer(4)      default(0), not null
#  article_price_id :integer(4)
#

