class Api::V1::ArticleCategoriesController < Api::V1::BaseController

  def index
    render json: ArticleCategory.all
  end

end
