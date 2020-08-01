class StockChange < ApplicationRecord
  belongs_to :delivery, optional: true, foreign_key: 'stock_event_id'
  belongs_to :order, optional: true
  belongs_to :stock_taking, optional: true, foreign_key: 'stock_event_id'
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
