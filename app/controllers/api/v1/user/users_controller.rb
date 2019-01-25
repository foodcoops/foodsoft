class Api::V1::User::UsersController < Api::V1::BaseController

  before_action ->{ doorkeeper_authorize! 'user:read', 'user:write' }

  def show
    render json: current_user
  end

end
