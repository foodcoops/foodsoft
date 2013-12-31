module OrderArticlesHelper

  def new_order_articles_collection
    if @order.stockit?
      StockArticle.order('articles.name')
    else
      @order.supplier.articles.undeleted.order('articles.name')
    end
  end
end
