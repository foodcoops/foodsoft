module StockitHelper
  def stock_article_classes(article)
    class_names = []
    class_names << "unavailable" if article.quantity_available <= 0
    class_names.join(" ")
  end
end
