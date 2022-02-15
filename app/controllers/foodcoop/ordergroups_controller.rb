class Foodcoop::OrdergroupsController < ApplicationController
  def index
    if params["sort"]
      sort = case params["sort"]
             when "name" then "name"
             when "name_reverse" then "name DESC"
             end
    else
      sort = "name"
    end

    @ordergroups = Ordergroup.undeleted.order(sort)

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
