class ArticlePrice < ApplicationRecord
  include LocalizeInput
  include PriceCalculation

  # @!attribute price
  #   @return [Number] Net price
  #   @see Article#price
  # @!attribute tax
  #   @return [Number] VAT percentage
  #   @see Article#tax
  # @!attribute deposit
  #   @return [Number] Deposit
  #   @see Article#deposit
  # @!attribute unit_quantity
  #   @return [Number] Number of units in wholesale package (box).
  #   @see Article#unit
  #   @see Article#unit_quantity
  # @!attribute article
  #   @return [Article] Article this price is about.
  belongs_to :article
  # @!attribute order_articles
  #   @return [Array<OrderArticle>] Order articles this price is associated with.
  has_many :order_articles

  localize_input_of :price, :tax, :deposit

  validates :price, :tax, :deposit, :unit_quantity, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_quantity, numericality: { greater_than: 0 }
  validates :deposit, :tax, numericality: true
end
