class StockArticle < Article
  has_many :stock_changes

  scope :available, -> { undeleted.with_latest_versions_and_categories.where('quantity > 0') }

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_destroy :check_quantity

  ransack_alias :quantity_available, :quantity # in-line with {StockArticleSerializer}

  def self.ransackable_attributes(auth_object = nil)
    super(auth_object) - %w[supplier_id] + %w[quantity]
  end

  def self.ransackable_associations(auth_object = nil)
    super(auth_object) - %w[supplier]
  end

  # Update the quantity of items in stock
  def update_quantity!
    update_attribute :quantity, stock_changes.collect(&:quantity).sum
  end

  # Check for unclosed orders and substract its ordered quantity
  def quantity_available
    quantity - quantity_ordered
  end

  def quantity_ordered
    OrderArticle.joins(:order, :article_version).where(article_versions: { article_id: id })
                .where(orders: { state: %w[open finished received] }).sum(:units_to_order)
  end

  def quantity_history
    stock_changes.reorder('stock_changes.created_at ASC').map { |s| s.quantity }.cumulative_sum
  end

  def self.stock_value
    available.collect { |a| a.quantity * a.gross_price }.sum
  end

  def mark_as_deleted
    check_quantity
    super
  end

  protected

  def check_quantity
    raise I18n.t('stockit.check.not_empty', name: name) unless quantity == 0
  end

  # Overwrite Price history of Article. For StockArticles isn't it necessary.
  def update_price_history
    true
  end
end
