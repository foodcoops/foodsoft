class Foodcoop::UsersController < ApplicationController

  def index
    @users = User.order('nick ASC')

    # if somebody uses the search field:
    unless params[:user_name].blank?
      @users = @users.where("first_name LIKE :user_name OR last_name LIKE :user_name OR nick LIKE :user_name",
                            user_name: "%#{params[:user_name]}%")
    end

    if params[:ordergroup_name]
      @users = @users.joins(:groups).where("groups.type = 'Ordergroup' AND groups.name LIKE ?", "%#{params[:ordergroup_name]}%")
    end

    @users = @users.page(params[:page]).per(@per_page).order('users.nick ASC')

    respond_to do |format|
      format.html # index.html.haml
      format.js { render :layout => false } # index.js.erb
    end
  end

end
