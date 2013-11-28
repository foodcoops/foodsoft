class UsersController < ApplicationController

  # Currently used to for user nick autocompletion
  def index
    @users = User.natural_search(params[:q])
    respond_to do |format|
      format.json { render :json => @users.map(&:token_attributes) }
    end
  end

end
