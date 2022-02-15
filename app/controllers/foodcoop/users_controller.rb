class Foodcoop::UsersController < ApplicationController
  def index
    if params["sort"]
      sort = case params["sort"]
               when "name" then "first_name, last_name"
               when "email" then "email"
               when "name_reverse" then "first_name DESC, last_name DESC"
               when "email_reverse" then "email DESC"
             end
    else
      sort = "first_name, last_name"
    end
    
    @users = User.undeleted.order(sort)

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
