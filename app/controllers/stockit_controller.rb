class StockitController < ApplicationController

  def index
    @stock_articles = StockArticle.includes(:supplier, :article_category).
        order('suppliers.name, article_categories.name, articles.name')
  end

  def new
    @stock_article = StockArticle.new
  end

  def create
    @stock_article = StockArticle.new(params[:stock_article])
    if @stock_article.save
      redirect_to stock_articles_path, :notice => "Lagerartikel wurde gespeichert."
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
      redirect_to stock_articles_path, :notice => "Lagerartikel wurde gespeichert."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @article = StockArticle.find(params[:id])
    @article.destroy
    render :layout => false
  rescue => error
    render :partial => "destroy_fail", :layout => false,
      :locals => { :fail_msg => "Ein Fehler ist aufgetreten: " + error.message }
  end

  #TODO: Fix this!!
  def articles_search
    @articles = Article.not_in_stock.limit(8).where('name LIKE ?', "%#{params[:term]}%")
    render :json => @articles.map(&:name)
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
