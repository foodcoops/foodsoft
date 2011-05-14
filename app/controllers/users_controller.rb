class UsersController < ApplicationController

  # Currently used to display users nick and ids for autocomplete
  def index
    @users = User.where("nick LIKE ?", "%#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @users.map { |u| {:id => u.id, :name => u.nick} } }
    end
  end

end
