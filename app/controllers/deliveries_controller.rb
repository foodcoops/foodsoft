# encoding: utf-8
class DeliveriesController < ApplicationController

  before_filter :find_supplier, :exclude => :fill_new_stock_article_form
  
  def index
    @deliveries = @supplier.deliveries.all :order => 'delivered_on DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deliveries }
    end
  end

  def show
    @delivery = Delivery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @delivery }
    end
  end

  def new
    @delivery = @supplier.deliveries.build
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @delivery }
    end
  end

  def create
    @delivery = Delivery.new(params[:delivery])

    respond_to do |format|
      if @delivery.save
        flash[:notice] = I18n.t('deliveries.create.notice')
        format.html { redirect_to([@supplier,@delivery]) }
        format.xml  { render :xml => @delivery, :status => :created, :location => @delivery }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @delivery.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @delivery = Delivery.find(params[:id])
  end
  
  def update
    @delivery = Delivery.find(params[:id])

    respond_to do |format|
      if @delivery.update_attributes(params[:delivery])
        flash[:notice] = I18n.t('deliveries.update.notice')
        format.html { redirect_to([@supplier,@delivery]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @delivery.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @delivery = Delivery.find(params[:id])
    @delivery.destroy

    flash[:notice] = I18n.t('deliveries.destroy.notice')
    respond_to do |format|
      format.html { redirect_to(supplier_deliveries_url(@supplier)) }
      format.xml  { head :ok }
    end
  end

  def add_stock_article
    article = @supplier.stock_articles.build(params[:stock_article])
    render :update do |page|
      if article.save
        logger.debug "new StockArticle: #{article.id}"
        page.insert_html :bottom, 'stock_changes', :partial => 'stock_change',
          :locals => {:stock_change => article.stock_changes.build, :supplier => @supplier}

        page.replace_html 'new_stock_article', :partial => 'stock_article_form',
          :locals => {:stock_article => @supplier.stock_articles.build}
      else
        page.replace_html 'new_stock_article', :partial => 'stock_article_form',
          :locals => {:stock_article => article}
      end
    end
  end

  def add_stock_change
    render :layout => false
  end

  def fill_new_stock_article_form
    article = Article.find(params[:article_id])
    @supplier = article.supplier
    stock_article = @supplier.stock_articles.build(
      article.attributes.reject { |attr| attr == ('id' || 'type')}
    )

    render :partial => 'stock_article_form', :locals => {:stock_article => stock_article}
  end
end
