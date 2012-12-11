class ArticlePrice < ActiveRecord::Base

  belongs_to :article
  has_many :order_articles

  validates_presence_of :price, :tax, :deposit, :unit_quantity
  validates_numericality_of :price, :unit_quantity, :greater_than => 0
  validates_numericality_of :deposit, :tax

  localize_input_of :price, :tax, :deposit

  # The financial gross, net plus tax and deposit.
  def gross_price
    ((price + deposit) * (tax / 100 + 1)).round(2)
  end

  # The price for the foodcoop-member.
  def fc_price
    (gross_price  * (FoodsoftConfig[:price_markup] / 100 + 1)).round(2)
  end
end

