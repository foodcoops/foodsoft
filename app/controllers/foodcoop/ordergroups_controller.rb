class Foodcoop::OrdergroupsController < ApplicationController
  def index
    sort = if params["sort"]
             case params["sort"]
             when "name" then "name"
             when "name_reverse" then "name DESC"
             when "last_user_activity" then "last_user_activity"
             when "last_user_activity_reverse" then "last_user_activity DESC"
             end
           else
             "name"
           end

    @ordergroups = Ordergroup.undeleted.order(sort) # order by "orders.starts"

    unless params[:name].blank? # Search by name
      @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:name]}%")
    end

    if params[:only_active] # Select only active groups
      @ordergroups = @ordergroups.joins(:orders).where("orders.starts >= ?", Time.now.months_ago(3)).uniq
    end

    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :layout => false }
    end
  end
end
