class StockitController < ApplicationController

  def index
    @stock_articles = StockArticle.undeleted.includes(:supplier, :article_category).
        order('suppliers.name, article_categories.name, articles.name')
  end
  
  def index_on_stock_article_create # See publish/subscribe design pattern in /doc.
    @stock_article = StockArticle.find(params[:id])
    
    render :layout => false
  end

  def index_on_stock_article_update # See publish/subscribe design pattern in /doc.
    @stock_article = StockArticle.find(params[:id])
    
    render :layout => false
  end

  # three possibilites to fill a new_stock_article form
  # (1) start from blank or use params
  def new
    @stock_article = StockArticle.new(params[:stock_article])

    render :layout => false
  end
  
  # (2) StockArticle as template
  def copy
    @stock_article = StockArticle.find(params[:stock_article_id]).dup
    
    render :layout => false
  end
  
  # (3) non-stock Article as template
  def derive
    @stock_article = Article.find(params[:old_article_id]).becomes(StockArticle).dup
    
    render :layout => false
  end

  def create
    @stock_article = StockArticle.new(params[:stock_article])
    if @stock_article.valid? and @stock_article.save
      render :layout => false
    else
      render :action => 'new', :layout => false
    end
  end

  def edit
    @stock_article = StockArticle.find(params[:id])
    
    render :layout => false
  end

  def update
    @stock_article = StockArticle.find(params[:id])
    if @stock_article.update_attributes(params[:stock_article])
      render :layout => false
    else
      render :action => 'edit', :layout => false
    end
  end

  def show
    @stock_article = StockArticle.find(params[:id])
    @stock_changes = @stock_article.stock_changes.order('stock_changes.created_at DESC')
  end

  def show_on_stock_article_update # See publish/subscribe design pattern in /doc.
    @stock_article = StockArticle.find(params[:id])
    
    render :layout => false
  end

  def destroy
    @stock_article = StockArticle.find(params[:id])
    @stock_article.mark_as_deleted
    render :layout => false
  rescue => error
    render :partial => "destroy_fail", :layout => false,
      :locals => { :fail_msg => I18n.t('errors.general_msg', :msg => error.message) }
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
