module OrderArticlesHelper

  def new_order_articles_collection
    if @order.stockit?
      StockArticle.undeleted.reorder('articles.name')
    else
      @order.supplier.articles.undeleted.reorder('articles.name')
    end
  end
end
