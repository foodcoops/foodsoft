class Api::V1::GroupOrderArticlesController < Api::V1::BaseController
  include Concerns::CollectionScope

  before_action :require_ordergroup
  before_action :require_minimum_balance, only: [:create, :update] # destroy is ok
  before_action :require_enough_apples, only: [:create, :update] # destroy is ok
  # @todo allow decreasing amounts when minimum balance isn't met

  def index
    render_collection search_scope
  end

  def show
    goa = scope.find(params.require(:id))
    render_goa_with_oa(goa)
  end

  def create
    goa = nil
    GroupOrderArticle.transaction do
      oa = order_articles_scope.find(create_params.require(:order_article_id))
      go = current_ordergroup.group_orders.find_or_create_by!(order_id: oa.order_id)
      goa = go.group_order_articles.create!(order_article: oa)
      goa.update_quantities((create_params[:quantity] || 0).to_i, (create_params[:tolerance] || 0).to_i)
      oa.update_results!
      go.update_price!
    end
    render_goa_with_oa(goa)
  end

  def update
    goa = nil
    GroupOrderArticle.transaction do
      goa = scope.includes(:group_order_article_quantities).find(params.require(:id))
      goa.update_quantities((update_params[:quantity] || goa.quantity).to_i, (update_params[:tolerance] || goa.tolerance).to_i)
      goa.order_article.update_results!
      goa.group_order.update_price!
    end
    render_goa_with_oa(goa)
  end

  def destroy
    goa = nil
    GroupOrderArticle.transaction do
      goa = scope.find(params.require(:id))
      goa.destroy!
      goa.order_article.update_results!
      goa.group_order.update_price!
    end
    render_goa_with_oa(nil, goa.order_article)
  end

  private

  def max_per_page
    nil
  end

  def scope
    current_ordergroup.group_order_articles.
      preload(order_article: :article).
      joins(group_order: :order).merge(Order.open)
  end

  def order_articles_scope
    OrderArticle.joins(:order).merge(Order.open)
  end

  def create_params
    params.require(:group_order_article).permit(:order_article_id, :quantity, :tolerance)
  end

  def update_params
    params.require(:group_order_article).permit(:quantity, :tolerance)
  end

  def require_minimum_balance
    minimum_balance = FoodsoftConfig[:minimum_balance] or return
    if current_ordergroup.account_balance < minimum_balance
      raise Api::Errors::PermissionRequired.new(t('application.controller.error_minimum_balance', min: minimum_balance))
    end
  end

  def require_enough_apples
    if current_ordergroup.not_enough_apples?
      s = t('group_orders.messages.not_enough_apples', apples: current_ordergroup.apples, stop_ordering_under: FoodsoftConfig[:stop_ordering_under])
      raise Api::Errors::PermissionRequired.new(s)
    end
  end

  def render_goa_with_oa(goa, oa = goa.order_article)
    data = {}
    data[:group_order_article] = GroupOrderArticleSerializer.new(goa) if goa
    data[:order_article] = OrderArticleSerializer.new(oa) if oa

    render json: data, root: nil
  end
end
