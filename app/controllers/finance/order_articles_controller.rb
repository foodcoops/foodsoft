class Finance::OrderArticlesController < ApplicationController

  before_filter :authenticate_finance

  layout false  # We only use this controller to serve js snippets, no need for layout rendering

  def new
    @order = Order.find(params[:order_id])
    @order_article = @order.order_articles.build
  end

  def create
    @order = Order.find(params[:order_id])
    @order_article = @order.order_articles.build(params[:order_article])
    unless @order_article.save
      render action: :new
    end
  end

  def edit
    @order = Order.find(params[:order_id])
    @order_article = OrderArticle.find(params[:id])
  end

  def update
    @order = Order.find(params[:order_id])
    @order_article = OrderArticle.find(params[:id])
    begin
      @order_article.update_article_and_price!(params[:article], params[:price], params[:order_article])
    rescue
      render action: :edit
    end
  end

  def destroy
    @order_article = OrderArticle.find(params[:id])
    @order_article.destroy
  end
end
