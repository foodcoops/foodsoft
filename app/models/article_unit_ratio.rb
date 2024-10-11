class ArticleUnitRatio < ApplicationRecord
  belongs_to :article_version

  default_scope { order(sort: :asc) }

  validates :quantity, :sort, :unit, presence: true
  validates :quantity, numericality: { greater_than: 0, less_than: 10**35 }
end
