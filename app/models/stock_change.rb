# == Schema Information
# Schema version: 20090317175355
#
# Table name: stock_changes
#
#  id               :integer         not null, primary key
#  delivery_id      :integer
#  order_id         :integer
#  stock_article_id :integer
#  quantity         :integer         default(0)
#  created_at       :datetime
#  stock_taking_id  :integer
#

class StockChange < ActiveRecord::Base
  belongs_to :delivery
  belongs_to :order
  belongs_to :stock_article

  validates_presence_of :stock_article_id, :quantity
  validates_numericality_of :quantity

  after_save :update_article_quantity
  after_destroy :update_article_quantity

  protected

  def update_article_quantity
    stock_article.update_quantity!
  end
end
