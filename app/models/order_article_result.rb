# An OrderArticleResult represents a single Article that is part of a *finished* Order.
# 
# Properties:
# * order_id	(int): association to the Order
# * name (string): article name
# * unit (string)
# * note (string): for post-editing the ordered article. informations like "new tax is ..."
# * net_price (decimal): the net price
# * gross_price (decimal): incl tax, deposit, fc-markup
# * tax	(int)
# * deposit	(decimal)
# * fc_markup (float) 
# * order_number (string)
# * unit_quantity (int): the internal(FC) size of trading unit
# * units_to_order	(int): number of packaging units to be ordered according to the order quantity/tolerance
#
class OrderArticleResult < ActiveRecord::Base
  belongs_to :order
  has_many :group_order_article_results, :dependent => :destroy
  
  validates_presence_of :name, :unit, :net_price, :gross_price, :tax, :deposit, :fc_markup, :unit_quantity, :units_to_order
  validates_numericality_of :net_price, :gross_price, :deposit, :unit_quantity, :units_to_order
  validates_length_of :name, :minimum => 4
  
  def make_gross # calculate the gross price and sets the attribute
    self.gross_price = ((net_price + deposit) * (tax / 100 + 1) * (fc_markup / 100 + 1))
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def net_price=(net_price)
    self[:net_price] = String.delocalized_decimal(net_price)
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def tax=(tax)
    self[:tax] = String.delocalized_decimal(tax)
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def deposit=(deposit)
    self[:deposit] = String.delocalized_decimal(deposit)
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def units_to_order=(units_to_order)
    self[:units_to_order] = String.delocalized_decimal(units_to_order)
  end
  
  # counts from every GroupOrderArticleResult for this ArticleResult
  # Return a hash with the total quantity (in Article-units) and the total (FC) price
  def total
    quantity = 0
    price = 0
    for result in self.group_order_article_results
      quantity += result.quantity
      price += result.quantity * self.gross_price
    end
    return {:quantity => quantity, :price => price}
  end
  
  
  # updates the price attribute for all appropriate GroupOrderResults
  def after_update
    group_order_article_results.each {|result| result.group_order_result.updatePrice}
  end
  
  protected
  
  def validate
    errors.add(:net_price, "should be positive") unless net_price.nil? || net_price > 0
  end
  
end
