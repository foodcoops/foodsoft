# encoding: utf-8
class CurrentOrders::ArticlesController < ApplicationController

  before_filter :authenticate_orders
  before_filter :find_order_and_order_article, only: [:index, :show]

  def index
    # sometimes need to pass id as parameter for forms
    show if @order_article
  end

  def show
    respond_to do |format|
      format.html { render :show }
      format.js   { render :show, layout: false }
    end
  end

  def show_on_group_order_article_create
    @goa = GroupOrderArticle.find(params[:group_order_article_id])
  end

  def show_on_group_order_article_update
    #@goa = GroupOrderArticle.find(params[:group_order_article_id])
  end

  protected

  def find_order_and_order_article
    @current_orders = Order.finished_not_closed
    unless params[:order_id].blank?
      @order = Order.find(params[:order_id])
      @order_articles = @order.order_articles
    else
      @order_articles = OrderArticle.where(order_id: @current_orders.all.map(&:id))
    end
    params[:q] ||= params[:search] # for meta_search instead of ransack
    @q = OrderArticle.search(params[:q])
    @order_articles = @order_articles.ordered.merge(@q.relation).includes(:article, :article_price)
    @order_article = @order_articles.where(id: params[:id]).first
  end

end
