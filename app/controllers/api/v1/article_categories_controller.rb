class Api::V1::ArticleCategoriesController < Api::V1::BaseController
  include Concerns::CollectionScope

  def index
    render json: search_scope
  end

  private

  def scope
    ArticleCategory.all
  end

end
