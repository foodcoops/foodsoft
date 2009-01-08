# == Schema Information
# Schema version: 20090102171850
#
# Table name: order_article_results
#
#  id             :integer(4)      not null, primary key
#  order_id       :integer(4)      default(0), not null
#  name           :string(255)     default(""), not null
#  unit           :string(255)     default(""), not null
#  note           :string(255)
#  net_price      :decimal(8, 2)   default(0.0)
#  gross_price    :decimal(8, 2)   default(0.0), not null
#  tax            :float           default(0.0), not null
#  deposit        :decimal(8, 2)   default(0.0)
#  fc_markup      :float           default(0.0), not null
#  order_number   :string(255)
#  unit_quantity  :integer(4)      default(0), not null
#  units_to_order :decimal(6, 3)   default(0.0), not null
#

# An OrderArticleResult represents a single Article that is part of a *finished* Order.
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
