class DeliveriesController < ApplicationController
  before_action :find_supplier, exclude: :fill_new_stock_article_form

  def index
    @deliveries = @supplier.deliveries.order('date DESC')
  end

  def show
    @delivery = Delivery.find(params[:id])
    @stock_changes = @delivery.stock_changes.includes(stock_article: :latest_article_version).order('article_versions.name ASC')
  end

  def new
    @delivery = @supplier.deliveries.build
    @delivery.date = Date.today # TODO: move to model/database
  end

  def edit
    @delivery = Delivery.find(params[:id])
  end

  def create
    @delivery = Delivery.new(params[:delivery])

    if @delivery.save
      flash[:notice] = I18n.t('deliveries.create.notice')
      redirect_to [@supplier, @delivery]
    else
      render action: 'new'
    end
  end

  def update
    @delivery = Delivery.find(params[:id])

    if @delivery.update(params[:delivery])
      flash[:notice] = I18n.t('deliveries.update.notice')
      redirect_to [@supplier, @delivery]
    else
      render action: 'edit'
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
    render layout: false
  end

  def form_on_stock_article_create # See publish/subscribe design pattern in /doc.
    @stock_article = StockArticle.find(params[:id])

    render layout: false
  end

  def form_on_stock_article_update # See publish/subscribe design pattern in /doc.
    @stock_article = StockArticle.find(params[:id])

    render layout: false
  end
end
