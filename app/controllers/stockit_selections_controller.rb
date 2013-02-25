# encoding: utf-8
class StockitSelectionsController < ApplicationController
  
  def index
    @stock_article_selections = StockArticleSelection.find(:all, :order => 'created_at DESC')
  end

  def show
    @stock_article_selection = StockArticleSelection.find(params[:id])
  end

  def create
    @stock_article_selection = StockArticleSelection.new(params[:stock_article_selection])
    @stock_article_selection.created_by = current_user

    if @stock_article_selection.save
      redirect_to(@stock_article_selection, :notice => 'Löschvorschlag für gewählte Artikel erstellt.')
    else
      @stock_articles = StockArticle.elements_for_index
      render 'stockit/index'
    end
  end

  def destroy # destroy selection without deleting articles
    stock_article_selection = StockArticleSelection.find(params[:id])
    stock_article_selection.destroy
    
    redirect_to stock_article_selections_path, :notice => 'Löschvorschlag verworfen.'
  end

  def articles # destroy articles
    stock_article_selection = StockArticleSelection.find(params[:id])
    
    destroyed_articles_count = 0
    failed_articles_count = 0
    stock_article_selection.stock_articles.each do |article|
      begin
        article.destroy
        destroyed_articles_count += 1
      rescue => error # recover if article.destroy fails and continue with next article
        failed_articles_count += 1
      end
    end
    
    if destroyed_articles_count > 0
      flash[:notice] = "#{destroyed_articles_count} gewählte Artikel gelöscht."
      flash[:error] = "#{failed_articles_count} Artikel konnten nicht gelöscht werden." unless 0==failed_articles_count
    else
      flash[:error] = 'Löschvorgang fehlgeschlagen. Keine Artikel gelöscht.'
    end
    
    redirect_to stock_articles_path
  end

  def finished # delete all finished selections
    finished_selections = StockArticleSelection.all.select { |sel| sel.deletable_count + sel.nondeletable_count <= 0 }
    finished_selections.each { |sel| sel.destroy }
    
    redirect_to stock_article_selections_path, :notice => 'Alle erledigten Löschvorschläge entfernt.'
  end
end
