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
  def quantity_available(exclude_order = nil)
    available = quantity
    for order in Order.stockit.all(:conditions => "state = 'open' OR state = 'finished'")
      unless order == exclude_order
        order_article = order.order_articles.first(:conditions => {:article_id => id})
        available -= order_article.units_to_order if order_article
      end
    end
    available
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

