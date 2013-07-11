#encoding: utf-8
class StockChangesController < ApplicationController
  before_filter :find_stock_article
  
  def index
    @stock_changes = @stock_article.stock_changes.order('stock_changes.created_at DESC').each {|s| s.readonly!}
  end
end
