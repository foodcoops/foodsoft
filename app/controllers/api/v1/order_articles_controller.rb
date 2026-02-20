class Api::V1::OrderArticlesController < Api::BaseController
  include Concerns::CollectionScope

  ORDER_ARTICLE_SERIALIZER = V1OrderArticleSerializer

  before_action -> { doorkeeper_authorize! 'orders:read', 'orders:write' }

  def index
    render_collection search_scope, include: ['article', 'article.article_unit_ratios'], each_serializer: self.class::ORDER_ARTICLE_SERIALIZER
  end

  def show
    render json: scope.find(params.require(:id)), include: ['article', 'article.article_unit_ratios'], serializer: self.class::ORDER_ARTICLE_SERIALIZER
  end

  private

  def scope
    OrderArticle.includes(article_version: { article: :supplier, article_unit_ratios: {} })
  end

  def search_scope
    merge_ordered_scope(super, params.fetch(:q, {})[:ordered])
  end

  def merge_ordered_scope(scope, ordered)
    if ordered.blank?
      scope
    elsif ordered == 'member' && current_ordergroup
      scope.joins(:group_order_articles).merge(current_ordergroup.group_order_articles)
    elsif ordered == 'all'
      table = scope.arel_table
      scope.where(table[:quantity].gt(0).or(table[:tolerance].gt(0)))
    elsif ordered == 'supplier'
      scope.ordered
    else
      scope.none # as a hint that it's an invalid value
    end
  end
end
