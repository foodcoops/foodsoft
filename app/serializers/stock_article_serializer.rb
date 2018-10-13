class StockArticleSerializer < ArticleSerializer
  attribute :quantity_available

  def quantity_available
    object.quantity
  end
end
