class UsersController < ApplicationController

  # Currently used to for user nick autocompletion
  def index
    users = User.where("nick LIKE ?", "%#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => search_data(users, proc {|o| o.nick_with_ordergroup }) }
    end
  end

end
