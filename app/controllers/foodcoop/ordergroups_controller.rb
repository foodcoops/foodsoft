class Foodcoop::OrdergroupsController < ApplicationController
  def index
    sort = if params["sort"]
             case params["sort"]
             when "name" then "name"
             when "name_reverse" then "name DESC"
             when "last_user_activity" then "users.last_activity"
             when "last_user_activity_reverse" then "users.last_activity DESC"
             when "last_order" then "max(orders.starts)"
             when "last_order_reverse" then "max(orders.starts) DESC"
             end
           else
             "name"
           end

    case params["sort"]
    when "last_user_activity", "last_user_activity_reverse" then @ordergroups = Ordergroup.left_joins(:users).undeleted.order(sort).distinct
    when "last_order", "last_order_reverse" then @ordergroups = Ordergroup.left_joins(:orders).group("groups.id").undeleted.order(sort).distinct
      # tp Ordergroup.left_joins(:orders).order("orders.starts"), "name", "orders.starts"
    else
      @ordergroups = Ordergroup.undeleted.order(sort)
    end

    unless params[:name].blank? # Search by name
      @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:name]}%")
    end

    if params[:only_active] # Select only active groups
      @ordergroups = @ordergroups.joins(:orders).where("orders.starts >= ?", Time.now.months_ago(3)).distinct
    end

    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :layout => false }
    end
  end
end
