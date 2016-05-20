module Concerns::CollectionScope
  extend ActiveSupport::Concern

  private

  def scope
    raise NotImplementedError, "Please override #scope when you use Concerns::CollectionScope"
  end

  def default_per_page
    20
  end

  def max_per_page
    250
  end

  def per_page
    [(params[:per_page] || default_per_page).to_i, max_per_page].compact.min
  end

  def search_scope
    s = params[:q] ? scope.ransack(params[:q]).result(distinct: true) : scope
    s = s.page(params[:page].to_i).per(per_page) if per_page >= 0
    s
  end

  def render_collection(scope)
    render json: scope, meta: collection_meta(scope)
  end

  def collection_meta(scope, extra = {})
    if scope.respond_to?(:total_count) && per_page
      {
        page: params[:page].to_i,
        per_page: per_page,
        total_pages: (scope.total_count / [1, per_page].max).ceil,
        total_count: scope.total_count
      }.merge(extra)
    end
  end

end
