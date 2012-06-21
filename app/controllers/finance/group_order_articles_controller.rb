class Finance::GroupOrderArticlesController < ApplicationController

  before_filter :authenticate_finance

  layout false  # We only use this controller to server js snippets, no need for layout rendering

  def new
    @order_article = OrderArticle.find(params[:order_article_id])
  end
end
