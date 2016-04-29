class Api::V1::OrderArticlesController < Api::V1::BaseController
  include CollectionScope

  before_action :authenticate

  def index
    render json: search_scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def scope
    OrderArticle.joins(:order).merge(Order.open).includes(:article, :article_price)
  end
end
