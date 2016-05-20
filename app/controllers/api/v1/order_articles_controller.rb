class Api::V1::OrderArticlesController < Api::V1::BaseController
  include Concerns::CollectionScope

  before_action :authenticate

  def index
    render_collection search_scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def scope
    OrderArticle.joins(:order).merge(Order.open).includes(:article, :article_price)
  end

  def search_scope
    merge_ordered_scope(super, params.fetch(:q, {})[:ordered])
  end

  def merge_ordered_scope(scope, ordered)
    if ordered.blank?
      scope
    elsif ordered == 'member'
      scope.joins(:group_order_articles).merge(current_ordergroup.group_order_articles)
    elsif ordered == 'all'
      scope.where('quantity > 0 OR tolerance > 0')
    elsif ordered == 'supplier'
      scope.ordered
    else
      scope.none # as a hint that it's an invalid value
    end
  end
end
