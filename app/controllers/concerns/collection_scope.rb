module Concerns::CollectionScope
  extend ActiveSupport::Concern

  private

  def scope
    raise NotImplementedError, 'Please override #scope when you use Concerns::CollectionScope'
  end

  def default_per_page
    20
  end

  def max_per_page
    250
  end

  def per_page
    # allow max_per_page and default_per_page to be nil as well
    if params[:per_page]
      [params[:per_page].to_i, max_per_page].compact.min
    else
      default_per_page
    end
  end

  def search_scope
    s = scope
    s = s.ransack(params[:q], auth_object: ransack_auth_object).result(distinct: true) if params[:q]
    s = s.page(params[:page].to_i).per(per_page) if per_page && per_page >= 0
    s
  end

  def render_collection(scope, params = {})
    render(json: scope, meta: collection_meta(scope), **params)
  end

  def collection_meta(scope, extra = {})
    return unless scope.respond_to?(:total_count) && per_page

    {
      page: params[:page].to_i,
      per_page: per_page,
      total_pages: (scope.total_count / [1, per_page].max).ceil,
      total_count: scope.total_count
    }.merge(extra)
  end

  # By default, there are no special ransack search scope authentications.
  # Controllers can override this to return something else and customize a model's
  # +ransackable_attributes+ and +ransackable_associations+ to allow searching on more
  # parameters in one controller than another (e.g. to protect searches that are scoped
  # to a user, while still allowing all search parameters for another endpoint).
  def ransack_auth_object
    nil
  end
end
