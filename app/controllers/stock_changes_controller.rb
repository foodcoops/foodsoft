#encoding: utf-8
class StockChangesController < ApplicationController
  before_filter :find_stock_article
  
  def index
    @stock_changes = @stock_article.stock_changes(:readonly => true).order('stock_changes.created_at DESC') # The readonly has no effect, what is the proper way to achieve that?
  end
end
