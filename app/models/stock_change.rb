# == Schema Information
# Schema version: 20090119155930
#
# Table name: stock_changes
#
#  id          :integer         not null, primary key
#  delivery_id :integer
#  order_id    :integer
#  article_id  :integer
#  quantity    :decimal(6, 2)   default(0.0)
#  created_at  :datetime
#

class StockChange < ActiveRecord::Base
  belongs_to :delivery
  belongs_to :order
  belongs_to :article

  validates_presence_of :article_id, :quantity
  validates_numericality_of :quantity

  after_save :update_article_quantity
  after_destroy :remove_added_quantity

  protected

  def update_article_quantity
    article.update_quantity(quantity)
  end

  def remove_added_quantity
    article.update_quantity(quantity * -1)
  end
end
