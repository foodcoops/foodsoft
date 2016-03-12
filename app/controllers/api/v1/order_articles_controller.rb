class Api::V1::OrderArticlesController < Api::V1::BaseController

  before_action :authenticate

  def index
    render json: scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def scope
    OrderArticle.joins(:order).merge(Order.open).includes(:article, :article_price)
  end
end
