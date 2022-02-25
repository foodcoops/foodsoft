class Foodcoop::UsersController < ApplicationController
  def index
    sort = if params["sort"]
             case params["sort"]
             when "name" then "first_name, last_name"
             when "name_reverse" then "first_name DESC, last_name DESC"
             when "email" then "email"
             when "email_reverse" then "email DESC"
             when "phone" then "phone"
             when "phone_reverse" then "phone DESC"
             when "ordergroup" then "groups.name"
             when "ordergroup_reverse" then "groups.name DESC"
             end
           else
             "first_name, last_name"
           end

    case params["sort"]
    when "ordergroup", "ordergroup_reverse" then @users = User.left_joins(:groups).where("groups.type = 'Ordergroup'").undeleted.order(sort).distinct
    else
      @users = User.undeleted.order(sort)
    end

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
