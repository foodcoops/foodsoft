class ArticlePrice < ActiveRecord::Base

  belongs_to :article
  has_many :order_articles

  validates_presence_of :price, :tax, :deposit, :unit_quantity
  validates_numericality_of :price, :unit_quantity, :greater_than => 0
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def price=(price)
    self[:price] = String.delocalized_decimal(price)
  end

  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def tax=(tax)
    self[:tax] = String.delocalized_decimal(tax)
  end

  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def deposit=(deposit)
    self[:deposit] = String.delocalized_decimal(deposit)
  end

  # The financial gross, net plus tax and deposit.
  def gross_price
    ((price + deposit) * (tax / 100 + 1)).round(2)
  end

  # The price for the foodcoop-member.
  def fc_price
    (gross_price  * (Foodsoft.config[:price_markup] / 100 + 1)).round(2)
  end
end

# == Schema Information
#
# Table name: article_prices
#
#  id            :integer(4)      not null, primary key
#  article_id    :integer(4)
#  price         :decimal(8, 2)   default(0.0), not null
#  tax           :decimal(8, 2)   default(0.0), not null
#  deposit       :decimal(8, 2)   default(0.0), not null
#  unit_quantity :integer(4)
#  created_at    :datetime
#

