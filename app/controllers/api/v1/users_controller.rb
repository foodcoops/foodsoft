class Api::V1::UsersController < Api::V1::BaseController

  before_action :authenticate

  def show
    render json: current_user
  end

end
