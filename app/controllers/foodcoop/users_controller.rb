class Foodcoop::UsersController < ApplicationController
  before_action -> { require_config_disabled :disable_members_overview }

  def index
    @users = User.undeleted.sort_by_param(params["sort"])

    # if somebody uses the search field:
    @users = @users.natural_search(params[:user_name]) unless params[:user_name].blank?

    if params[:ordergroup_name]
      @users = @users.joins(:groups).where("groups.type = 'Ordergroup' AND groups.name LIKE ?", "%#{params[:ordergroup_name]}%")
    end

    @users = @users.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.html # index.html.haml
      format.js { render :layout => false } # index.js.erb
    end
  end
end
