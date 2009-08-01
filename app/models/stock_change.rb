# == Schema Information
#
# Table name: stock_changes
#
#  id               :integer(4)      not null, primary key
#  delivery_id      :integer(4)
#  order_id         :integer(4)
#  stock_article_id :integer(4)
#  quantity         :integer(4)      default(0)
#  created_at       :datetime
#  stock_taking_id  :integer(4)
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
