class Api::V1::OrdersController < Api::V1::BaseController
  include Concerns::CollectionScope

  before_action :authenticate

  def index
    render json: search_scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def scope
    Order.open.includes(:supplier)
  end
end
