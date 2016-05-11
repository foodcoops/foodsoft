class Api::V1::GroupOrderArticlesController < Api::V1::BaseController
  include Concerns::CollectionScope

  before_action :require_ordergroup

  def index
    render json: search_scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  def create
    GroupOrderArticle.transaction do
      oa = order_articles_scope.find(create_params.require(:order_article_id))
      go = current_ordergroup.group_orders.find_or_create_by!(order_id: oa.order_id)
      goa = go.group_order_articles.create!(create_params)
      oa.update_results!
      go.update_price!
      render json: goa
    end
  end

  def update
    GroupOrderArticle.transaction do
      goa = scope.includes(:group_order_article_quantities).find(params.require(:id))
      goa.update_quantities((update_params[:quantity] || goa.quantity).to_i, (update_params[:tolerance] || goa.tolerance).to_i)
      goa.order_article.update_results!
      goa.group_order.update_price!
      render json: goa
    end
  end

  def destroy
    GroupOrderArticle.transaction do
      goa = scope.find(params.require(:id))
      goa.destroy!
      goa.order_article.update_results!
      goa.group_order.update_price!
    end
    head :no_content
  end

  private

  def scope
    current_ordergroup.group_order_articles.
      preload(:order_article => :article).
      joins(:group_order => :order).merge(Order.open)
  end

  def order_articles_scope
    OrderArticle.joins(:order).merge(Order.open)
  end

  def create_params
    params.permit(:order_article_id, :quantity, :tolerance)
  end

  def update_params
    params.permit(:quantity, :tolerance)
  end
end
