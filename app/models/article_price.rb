class ArticlePrice < ActiveRecord::Base

  belongs_to :article
  has_many :order_articles

  validates_presence_of :price, :tax, :deposit, :unit_quantity
  validates_numericality_of :price, :greater_than_or_equal_to => 0
  validates_numericality_of :unit_quantity, :greater_than => 0
  validates_numericality_of :deposit, :tax

  localize_input_of :price, :tax, :deposit

  def gross_price(group=nil)
    ArticlePrice.gross_price(self, group)
  end

  def fc_price(group=nil)
    ArticlePrice.fc_price(self, group)
  end


  # The financial gross, net plus tax and deposit.
  def self.gross_price(price, group=nil)
    ((price.price + price.deposit) * (price.tax / 100 + 1)).round(2)
  end

  # The price for the foodcoop-member.
  def self.fc_price(price, group=nil)
    (price.gross_price  * (ArticlePrice.markup_pct(group) / 100 + 1)).round(2)
  end

  # The markup percentage for the foodcoop-member.
  def self.markup_pct(group=nil)
    FoodsoftConfig[:price_markup]
  end
end

