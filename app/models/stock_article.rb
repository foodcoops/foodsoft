# encoding: utf-8
class StockArticle < Article
  acts_as_paranoid
  
  has_many :stock_changes

  scope :available, :conditions => "quantity > 0"

  before_destroy :check_quantity

  # Update the quantity of items in stock
  def update_quantity!
    update_attribute :quantity, stock_changes.collect(&:quantity).sum
  end

  # Check for unclosed orders and substract its ordered quantity
  def quantity_available
    quantity - OrderArticle.where(article_id: id).
        joins(:order).where("orders.state = 'open' OR orders.state = 'finished'").sum(:units_to_order)
  end

  def self.stock_value
    available.collect { |a| a.quantity * a.gross_price }.sum
  end

  protected

  def check_quantity
    raise "#{name} kann nicht gelöscht werden. Der Lagerbestand ist nicht null." unless quantity == 0
  end

  # Overwrite Price history of Article. For StockArticles isn't it necessary.
  def update_price_history
    true
  end
end

