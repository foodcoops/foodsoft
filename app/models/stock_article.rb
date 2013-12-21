# encoding: utf-8
class StockArticle < Article

  has_many :stock_changes

  scope :available, -> { undeleted.where'quantity > 0' }

  before_destroy :check_quantity

  # Update the quantity of items in stock
  def update_quantity!
    update_attribute :quantity, stock_changes.collect(&:quantity).sum
  end

  # Check for unclosed orders and substract its ordered quantity
  def quantity_available
    quantity - quantity_ordered
  end

  def quantity_ordered
    OrderArticle.where(article_id: id).
        joins(:order).where("orders.state = 'open' OR orders.state = 'finished'").sum(:units_to_order)
  end

  def quantity_history
    stock_changes.reorder('stock_changes.created_at ASC').map{|s| s.quantity}.cumulative_sum
  end

  def self.stock_value
    available.collect { |a| a.quantity * a.gross_price }.sum
  end

  def mark_as_deleted
    check_quantity
    super
  end

  protected

  def check_quantity
    raise I18n.t('stockit.check.not_empty', :name => name) unless quantity == 0
  end

  # Overwrite Price history of Article. For StockArticles isn't it necessary.
  def update_price_history
    true
  end
end

