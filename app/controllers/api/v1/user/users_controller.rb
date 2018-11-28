class Api::V1::User::UsersController < Api::V1::BaseController

  def show
    render json: current_user
  end

end
