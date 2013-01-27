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

  scope :in_open_orders, joins(:order).merge(Order.open)
  scope :in_finished_orders, joins(:order).merge(Order.finished_not_closed)

  # Generate some data for the javascript methods in ordering view
  def load_data
    data = {}
    data[:available_funds] = ordergroup.get_available_funds(self)

    unless new_record?
      # Group has already ordered, so get the results...
      goas = {}
      group_order_articles.all.each do |goa|
        goas[goa.order_article_id] = {
            :quantity => goa.quantity,
            :tolerance => goa.tolerance,
            :quantity_result => goa.result(:quantity),
            :tolerance_result => goa.result(:tolerance),
            :total_price => goa.total_price
        }
  end
    end

    # load prices and other stuff....
    data[:order_articles] = {}
    #order.order_articles.each do |order_article|
    order.articles_grouped_by_category.each do |article_category, order_articles|
      order_articles.each do |order_article|
        data[:order_articles][order_article.id] = {
            :price => order_article.article.fc_price,
            :unit => order_article.article.unit_quantity,
            :quantity => (new_record? ? 0 : goas[order_article.id][:quantity]),
            :others_quantity => order_article.quantity - (new_record? ? 0 : goas[order_article.id][:quantity]),
            :used_quantity => (new_record? ? 0 : goas[order_article.id][:quantity_result]),
            :tolerance => (new_record? ? 0 : goas[order_article.id][:tolerance]),
            :others_tolerance => order_article.tolerance - (new_record? ? 0 : goas[order_article.id][:tolerance]),
            :used_tolerance => (new_record? ? 0 : goas[order_article.id][:tolerance_result]),
            :total_price => (new_record? ? 0 : goas[order_article.id][:total_price]),
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
      group_order_article = group_order_articles.find_or_create_by_order_article_id(order_article.id)

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

