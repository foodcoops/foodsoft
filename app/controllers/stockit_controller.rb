class StockitController < ApplicationController
  def index
    @articles = Article.in_stock
  end

end
