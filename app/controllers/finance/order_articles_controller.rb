class Finance::OrderArticlesController < ApplicationController

  before_filter :authenticate_finance

  layout false  # We only use this controller to serve js snippets, no need for layout rendering

  def new
    @order = Order.find(params[:order_id])
    @order_article = @order.order_articles.build
  end

  def create
    @order = Order.find(params[:order_id])
    # The article may with zero units ordered - in that case find and set amount to nonzero.
    #   If order_article is ordered and a new order_article is created, an error message will be
    #   given mentioning that the article already exists, which is desired.
    @order_article = @order.order_articles.where(:article_id => params[:order_article][:article_id]).first
    if @order_article and @order_article.units_to_order == 0
      @order_article.units_to_order = 1
    else
      @order_article = @order.order_articles.build(params[:order_article])
    end
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
      @order_article.update_article_and_price!(params[:order_article], params[:article], params[:article_price])
    rescue
      render action: :edit
    end
  end

  def destroy
    @order_article = OrderArticle.find(params[:id])
    @order_article.destroy
  end
end
