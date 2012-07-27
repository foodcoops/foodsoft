class StockTaking < ActiveRecord::Base

  has_many :stock_changes, :dependent => :destroy
  has_many :stock_articles, :through => :stock_changes

  validates_presence_of :date

  def stock_change_attributes=(stock_change_attributes)
    for attributes in stock_change_attributes
      stock_changes.build(attributes) unless attributes[:quantity].to_i == 0
    end
  end
end

