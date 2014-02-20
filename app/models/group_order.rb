# A GroupOrder represents an Order placed by an Ordergroup.
class GroupOrder < ActiveRecord::Base

  attr_accessor :group_order_articles_attributes

  belongs_to :order
  belongs_to :ordergroup
  has_many :group_order_articles, :dependent => :destroy
  has_many :order_articles, :through => :group_order_articles
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_user_id"

  validates_presence_of :order_id
  validates_presence_of :ordergroup_id
  validates_numericality_of :price
  validates_uniqueness_of :ordergroup_id, :scope => :order_id   # order groups can only order once per order

  scope :in_open_orders, -> { joins(:order).merge(Order.open) }
  scope :in_finished_orders, -> { joins(:order).merge(Order.finished_not_closed) }

  scope :ordered, -> { includes(:ordergroup).order('groups.name') }

  # Generate some data for the javascript methods in ordering view
  def load_data
    data = {}
    data[:available_funds] = ordergroup.get_available_funds(self)

    # load prices and other stuff....
    data[:order_articles] = {}
    order.articles_grouped_by_category.each do |article_category, order_articles|
      order_articles.each do |order_article|
        
        # Get the result of last time ordering, if possible
        goa = group_order_articles.detect { |goa| goa.order_article_id == order_article.id }

        # Build hash with relevant data
        data[:order_articles][order_article.id] = {
            :price => order_article.article.fc_price,
            :unit => order_article.article.unit_quantity,
            :quantity => (goa ? goa.quantity : 0),
            :others_quantity => order_article.quantity - (goa ? goa.quantity : 0),
            :used_quantity => (goa ? goa.result(:quantity) : 0),
            :tolerance => (goa ? goa.tolerance : 0),
            :others_tolerance => order_article.tolerance - (goa ? goa.tolerance : 0),
            :used_tolerance => (goa ? goa.result(:tolerance) : 0),
            :total_price => (goa ? goa.total_price : 0),
            :missing_units => order_article.missing_units,
            :quantity_available => (order.stockit? ? order_article.article.quantity_available : 0)
        }
      end
    end

    data
  end

  def save_group_order_articles
    for order_article in order.order_articles
      # Find the group_order_article, create a new one if necessary...
      group_order_article = group_order_articles.where(order_article_id: order_article.id).first_or_create

      # Get ordered quantities and update group_order_articles/_quantities...
      quantities = group_order_articles_attributes.fetch(order_article.id.to_s, {:quantity => 0, :tolerance => 0})
      group_order_article.update_quantities(quantities[:quantity].to_i, quantities[:tolerance].to_i)

      # Also update results for the order_article
      logger.debug "[save_group_order_articles] update order_article.results!"
      order_article.update_results!
    end

    # set attributes to nil to avoid and infinite loop of
  end

  # Updates the "price" attribute.
  def update_price!
    total = group_order_articles.includes(:order_article => [:article, :article_price]).to_a.sum(&:total_price)
    update_attribute(:price, total)
  end


  # Save GroupOrder and updates group_order_articles/quantities accordingly
  def save_ordering!
    transaction do
      save!
      save_group_order_articles
      update_price!
    end
  end

end

