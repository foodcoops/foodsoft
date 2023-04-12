class OrderArticlesController < ApplicationController
  before_action :fetch_order, except: :destroy
  before_action :authenticate_finance_or_invoices, except: [:new, :create]
  before_action :authenticate_finance_orders_or_pickup, except: [:edit, :update, :destroy]

  layout false  # We only use this controller to serve js snippets, no need for layout rendering

  def new
    @order_article = @order.order_articles.build(params[:order_article])
  end

  def create
    # The article may be ordered with zero units - in that case do not complain.
    #   If order_article is ordered and a new order_article is created, an error message will be
    #   given mentioning that the article already exists, which is desired.
    @order_article = @order.order_articles.where(:article_id => params[:order_article][:article_id]).first
    unless @order_article && @order_article.units_to_order == 0
      @order_article = @order.order_articles.build(params[:order_article])
    end
    @order_article.save!
  rescue
    render action: :new
  end

  def edit
    @order_article = OrderArticle.find(params[:id])
  end

  def update
    @order_article = OrderArticle.find(params[:id])
    begin
      @order_article.update_article_and_price!(params[:order_article], params[:article], params[:article_price])
    rescue
      render action: :edit
    end
  end

  def destroy
    @order_article = OrderArticle.find(params[:id])
    # only destroy if there are no associated GroupOrders; if we would, the requested
    # quantity and tolerance would be gone. Instead of destroying, we set all result
    # quantities to zero.
    if @order_article.group_order_articles.count == 0
      @order_article.destroy
    else
      @order_article.group_order_articles.each { |goa| goa.update_attribute(:result, 0) }
      @order_article.update_results!
    end
  end

  private

  def fetch_order
    @order = Order.find(params[:order_id])
  end

  def authenticate_finance_orders_or_pickup
    return if current_user.role_finance? || current_user.role_orders?

    return if current_user.role_pickups? && !@order.nil? && @order.state == 'finished'

    deny_access
  end
end
