class Api::V1::GroupOrderArticlesController < Api::V1::BaseController
  include CollectionScope

  before_action :authenticate

  def index
    render json: scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def scope
    GroupOrderArticle.joins(:group_order => :order).merge(Order.open)
  end
end
