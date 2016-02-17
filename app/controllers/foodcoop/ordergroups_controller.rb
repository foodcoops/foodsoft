class Foodcoop::OrdergroupsController < ApplicationController
  
  def index
    @ordergroups = Ordergroup.undeleted.order('name')

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
