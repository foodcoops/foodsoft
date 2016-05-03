module Concerns::CollectionScope
  extend ActiveSupport::Concern

  private

  def scope
    raise NotImplementedError, "Please override #scope when you use the Api::Scope concern"
  end

  def search_scope
    params[:q] ? scope.ransack(params[:q]).result : scope
  end

end
