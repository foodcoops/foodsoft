class Foodcoop::UsersController < ApplicationController
  def index
    sort_param_map = {
      "nick" => "nick",
      "nick_reverse" => "nick DESC",
      "name" => "first_name, last_name",
      "name_reverse" => "first_name DESC, last_name DESC",
      "email" => "email",
      "email_reverse" => "email DESC",
      "phone" => "phone",
      "phone_reverse" => "phone DESC",
      "ordergroup" => "groups.name",
      "ordergroup_reverse" => "groups.name DESC"
    }
    @users = User.left_joins(:groups).where(groups: { type: 'Ordergroup' }).undeleted.order(sort_param_map[params["sort"]] || "first_name, last_name").distinct

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
