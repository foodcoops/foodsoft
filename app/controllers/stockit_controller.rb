class StockitController < ApplicationController
  def index
    @articles = StockArticle.all
  end

end
