module Finance::OrderArticlesHelper

  def new_order_articles_collection
    if @order.stockit?
      StockArticle.order(:name)
    else
      @order.supplier.articles.order(:name)
    end
  end
end
