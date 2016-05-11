module Concerns::CollectionScope
  extend ActiveSupport::Concern

  private

  def scope
    raise NotImplementedError, "Please override #scope when you use Concerns::CollectionScope"
  end

  def search_scope
    params[:q] ? scope.ransack(params[:q]).result(distinct: true) : scope
  end

end
