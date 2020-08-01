class Delivery < StockEvent

  belongs_to :supplier
  belongs_to :invoice, optional: true

  scope :recent, -> { order('created_at DESC').limit(10) }

  validates_presence_of :supplier_id
  validate :stock_articles_must_be_unique

  accepts_nested_attributes_for :stock_changes, :allow_destroy => :true

  def new_stock_changes=(stock_change_attributes)
    for attributes in stock_change_attributes
      stock_changes.build(attributes) unless attributes[:quantity].to_i == 0
    end
  end

  def includes_article?(article)
    self.stock_changes.map{|stock_change| stock_change.stock_article.id}.include? article.id
  end

  def sum(type = :gross)
    total = 0
    for sc in stock_changes
      article = sc.stock_article
      quantity = sc.quantity
      case type
        when :net
          total += quantity * article.price
        when :gross
          total += quantity * article.gross_price
        when :fc
          total += quantity * article.fc_price
      end
    end
    total
  end

  protected

  def stock_articles_must_be_unique
    unless stock_changes.reject{|sc| sc.marked_for_destruction?}.map {|sc| sc.stock_article.id}.uniq!.nil?
      errors.add(:base, I18n.t('model.delivery.each_stock_article_must_be_unique'))
    end
  end

end
