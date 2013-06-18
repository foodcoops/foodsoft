# encoding: utf-8
class DeliveriesController < ApplicationController

  before_filter :find_supplier, :exclude => :fill_new_stock_article_form
  
  def index
    @deliveries = @supplier.deliveries.all :order => 'delivered_on DESC'
  end

  def show
    @delivery = Delivery.find(params[:id])
  end

  def new
    @delivery = @supplier.deliveries.build
  end

  def create
    @delivery = Delivery.new(params[:delivery])
    
    if @delivery.save
      flash[:notice] = I18n.t('deliveries.create.notice')
      redirect_to [@supplier, @delivery]
    else
      render :action => "new"
    end
  end

  def edit
    @delivery = Delivery.find(params[:id])
  end
  
  def update
    @delivery = Delivery.find(params[:id])

    if @delivery.update_attributes(params[:delivery])
      flash[:notice] = I18n.t('deliveries.update.notice')
      redirect_to [@supplier,@delivery]
    else
      render :action => "edit"
    end
  end

  def destroy
    @delivery = Delivery.find(params[:id])
    @delivery.destroy

    flash[:notice] = I18n.t('deliveries.destroy.notice')
    redirect_to supplier_deliveries_url(@supplier)
  end

  def new_stock_article
    if params[:old_stock_article_id]
      old_article = StockArticle.find_by_id(params[:old_stock_article_id])
    elsif params[:old_article_id]
      old_article = Article.find_by_id(params[:old_article_id])
      old_article = old_article.becomes(StockArticle) unless old_article.nil?
    end
    
    unless old_article.nil?
      @stock_article = old_article.dup
    else
      @stock_article = @supplier.stock_articles.build
    end
    render :layout => false
  end

  def add_stock_article
    @stock_article = StockArticle.new(params[:stock_article])
    
    if @stock_article.valid? and @stock_article.save
      render :layout => false
    else
      render :action => 'new_stock_article', :layout => false
    end
  end

  def edit_stock_article
    @stock_article = StockArticle.find(params[:stock_article_id])
    render :layout => false
  end

  def update_stock_article
    @stock_article = StockArticle.find(params[:stock_article][:id])
    
    if @stock_article.update_attributes(params[:stock_article])
      render :layout => false
    else
      render :action => 'edit_stock_article', :layout => false
    end
  end

  def add_stock_change
    @stock_change = StockChange.new
    @stock_change.stock_article = StockArticle.find(params[:stock_article_id])
    render :layout => false
  end

end
