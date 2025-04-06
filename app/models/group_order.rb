# A GroupOrder represents an Order placed by an Ordergroup.
class GroupOrder < ApplicationRecord
  include FindEachWithOrder

  attr_accessor :group_order_articles_attributes

  belongs_to :order
  belongs_to :ordergroup, optional: true
  has_many :group_order_articles, dependent: :destroy
  has_many :order_articles, through: :group_order_articles
  has_one :financial_transaction
  belongs_to :updated_by, optional: true, class_name: 'User', foreign_key: 'updated_by_user_id'

  validates :order_id, presence: true
  validates :price, numericality: true
  validates :ordergroup_id, uniqueness: { scope: :order_id } # order groups can only order once per order

  scope :in_open_orders, -> { joins(:order).merge(Order.open) }
  scope :in_finished_orders, -> { joins(:order).merge(Order.finished_not_closed) }
  scope :stock, -> { where(ordergroup: 0) }

  scope :ordered, -> { includes(:ordergroup).order('groups.name') }

  def self.ransackable_attributes(_auth_object = nil)
    %w[id price]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[order group_order_articles]
  end

  # Generate some data for the javascript methods in ordering view
  def load_data
    data = {}
    data[:account_balance] = ordergroup.nil? ? BigDecimal('+Infinity') : ordergroup.account_balance
    data[:available_funds] = ordergroup.nil? ? BigDecimal('+Infinity') : ordergroup.get_available_funds(self)

    # load prices and other stuff....
    data[:order_articles] = {}
    order.articles_grouped_by_category.each do |_article_category, order_articles|
      order_articles.each do |order_article|
        # Get the result of last time ordering, if possible
        goa = group_order_articles.detect { |goa| goa.order_article_id == order_article.id }

        # Build hash with relevant data
        data[:order_articles][order_article.id] = {
          price: order_article.article_version.fc_group_order_price,
          unit: order_article.article_version.unit_quantity,
          quantity: (goa ? goa.quantity : 0),
          others_quantity: order_article.quantity - (goa ? goa.quantity : 0),
          used_quantity: (goa ? goa.result(:quantity) : 0),
          tolerance: (goa ? goa.tolerance : 0),
          others_tolerance: order_article.tolerance - (goa ? goa.tolerance : 0),
          used_tolerance: (goa ? goa.result(:tolerance) : 0),
          total_price: (goa ? goa.total_price : 0),
          missing_units: order_article.missing_units,
          ratio_group_order_unit_supplier_unit: order_article.article_version.convert_quantity(1,
                                                                                               order_article.article_version.supplier_order_unit, order_article.article_version.group_order_unit),
          quantity_available: (order.stockit? ? order_article.article_version.article.quantity_available : 0),
          minimum_order_quantity: if order_article.article_version.minimum_order_quantity
                                    order_article.article_version.convert_quantity(
                                      order_article.article_version.minimum_order_quantity, order_article.article_version.supplier_order_unit, order_article.article_version.group_order_unit
                                    )
                                  end
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
      if group_order_articles_attributes
        quantities = group_order_articles_attributes.fetch(order_article.id.to_s, { quantity: 0, tolerance: 0 })
        group_order_article.update_quantities(quantities[:quantity].to_f, quantities[:tolerance].to_f)
      end

      # Also update results for the order_article
      logger.debug '[save_group_order_articles] update order_article.results!'
      order_article.update_results!
    end

    # set attributes to nil to avoid and infinite loop of
  end

  # Updates the "price" attribute.
  def update_price!
    total = group_order_articles.includes(order_article: :article_version).to_a.sum(&:total_price)
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

  def ordergroup_name
    ordergroup ? ordergroup.name : I18n.t('model.group_order.stock_ordergroup_name', user: updated_by.try(:name) || '?')
  end

  def total
    return price + transport if transport

    price
  end
end
