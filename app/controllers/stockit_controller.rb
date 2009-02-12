class StockitController < ApplicationController

  def index
    @stock_articles = StockArticle.without_deleted(
      :include => [:supplier, :article_category],
      :order => 'suppliers.name, article_categories.name, articles.name'
    )
  end

  def new
    @supplier = Supplier.find(params[:supplier_id])
    @stock_article = @supplier.stock_articles.build(:tax => 7.0)
  rescue
    flash[:error] = "Es wurde kein gültiger Lieferant ausgewählt."
    redirect_to stock_articles_path
  end

  def create
    @stock_article = StockArticle.new(params[:stock_article])
    if @stock_article.save
      redirect_to stock_articles_path
    else
      render :action => 'new'
    end
  end

  def edit
    @stock_article = StockArticle.find(params[:id])
  end

  def update
    @stock_article = StockArticle.find(params[:id])
    if @stock_article.update_attributes(params[:stock_article])
      redirect_to stock_articles_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    StockArticle.find(params[:id]).destroy
    redirect_to stock_articles_path
  rescue => error
    flash[:error] = "Ein Fehler ist aufgetreten: " + error.message
    redirect_to stock_articles_path
  end

  def auto_complete_for_article_name
    @supplier = Supplier.find(params[:supplier_id])
    @articles = @supplier.articles.without_deleted.find(:all,
      :conditions => [ "LOWER(articles.name) LIKE ?", '%' + params[:article][:name].downcase + '%' ],
      :limit => 8)
    render :partial => 'shared/auto_complete_articles'
  end

  def fill_new_stock_article_form
    article = Article.find(params[:article_id])
    @supplier = article.supplier
    stock_article = @supplier.stock_articles.build(
      article.attributes.reject { |attr| attr == ('id' || 'type')}
    )

    render :partial => 'form', :locals => {:stock_article => stock_article}
  end
end
