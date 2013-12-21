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
    @delivery.delivered_on = Date.today #TODO: move to model/database
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
  
  def add_stock_change
    @stock_change = StockChange.new
    @stock_change.stock_article = StockArticle.find(params[:stock_article_id])
    render :layout => false
  end
  
  def form_on_stock_article_create # See publish/subscribe design pattern in /doc.
    @stock_article = StockArticle.find(params[:id])
    
    render :layout => false
  end

  def form_on_stock_article_update # See publish/subscribe design pattern in /doc.
    @stock_article = StockArticle.find(params[:id])
    
    render :layout => false
  end

end
