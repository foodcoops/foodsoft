#encoding: utf-8
class StockChangesController < ApplicationController
  
  def index
    @stock_article = StockArticle.undeleted.find(params[:stock_article_id])
    @stock_changes = @stock_article.stock_changes.order('stock_changes.created_at DESC').each {|s| s.readonly!}
  end
end
