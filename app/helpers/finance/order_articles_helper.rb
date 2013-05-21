module Finance::OrderArticlesHelper

  def new_order_articles_collection
    if @order.stockit?
      StockArticle.order('articles.name')
    else
      @order.supplier.articles.order('articles.name')
    end
  end
end
