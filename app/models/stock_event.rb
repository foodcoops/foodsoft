class StockEvent < ApplicationRecord
  has_many :stock_changes, dependent: :destroy
  has_many :stock_articles, through: :stock_changes

  validates :date, presence: true
end
