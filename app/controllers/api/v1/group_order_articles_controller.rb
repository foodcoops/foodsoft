class Api::V1::GroupOrderArticlesController < Api::V1::BaseController
  include Concerns::CollectionScope

  before_action :require_ordergroup

  def index
    render json: scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def scope
    current_ordergroup.group_order_articles.joins(:group_order => :order).merge(Order.open)
  end
end
