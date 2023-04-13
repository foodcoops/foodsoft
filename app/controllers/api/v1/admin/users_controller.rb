class Api::V1::Admin::UsersController < Api::V1::BaseController
  include Concerns::CollectionScope

  before_action -> { doorkeeper_authorize! 'user:read', 'user:write' }


  def index
    render_collection search_scope
  end

  # def show
  #   render json: scope #.find(params.require(:id))
  # end

  private

  def scope
    User.undeleted #OrderArticle.includes(:article_price, article: :supplier)
  end

end
