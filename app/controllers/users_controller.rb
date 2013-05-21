class UsersController < ApplicationController

  # Currently used to display users nick and ids for autocomplete
  def index
    @users = User.where("nick LIKE ?", "%#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @users.map { |u| u.token_attributes } }
    end
  end

end
