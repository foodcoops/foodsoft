# encoding: utf-8
class StockitSelectionsController < ApplicationController
  
  def index
    @stock_article_selections = StockArticleSelection.all
  end

  def show
    @stock_article_selection = StockArticleSelection.find(params[:id])
  end

  def create
    @stock_article_selection = StockArticleSelection.new(params[:stock_article_selection])
    @stock_article_selection.created_by = current_user

    if @stock_article_selection.save
      redirect_to(@stock_article_selection, :notice => 'Löschvorschlag für gewählte Artikel wurde erstellt.')
    else
      @stock_articles = StockArticle.includes(:supplier, :article_category).
          order('suppliers.name, article_categories.name, articles.name')
      render 'stockit/index'
    end
  end

  def destroy # destroy (open or finished) selection without deleting articles
    stock_article_selection = StockArticleSelection.find(params[:id])
    stock_article_selection.destroy
    
    redirect_to stock_article_selections_path, :notice => 'Löschvorschlag wurde verworfen.'
  end

  def articles # destroy articles, finish selection
    stock_article_selection = StockArticleSelection.find(params[:id])
    
    destroyed_articles_count = 0
    failed_articles_count = 0
    stock_article_selection.stock_articles.each do |article|
      begin
        article.destroy # article.delete would save some effort, but validations are important
        destroyed_articles_count += 1
      rescue => error # recover if article.destroy fails and continue with next article
        failed_articles_count += 1
      end
    end
    
    if destroyed_articles_count>0 # note that 1 successful article.destroy is enough to destroy selection
      stock_article_selection.destroy
      flash[:notice] = "#{destroyed_articles_count} gewählte Artikel sind nun gelöscht."
      flash[:error] = "#{failed_articles_count} Artikel konnten nicht gelöscht werden." unless 0==failed_articles_count
    else
      flash[:error] = "Löschvorgang fehlgeschlagen. Es wurden keine Artikel gelöscht."
    end
    
    redirect_to stock_articles_path
  end
end
