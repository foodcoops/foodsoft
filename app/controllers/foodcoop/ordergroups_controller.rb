class Foodcoop::OrdergroupsController < ApplicationController
  
  def index
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end

    @ordergroups = Ordergroup.order(:name.desc)
    @ordergroups = @ordergroups.where(:name.matches => "%#{params[:query]}%") unless params[:query].blank? # Search by name
    @ordergroups = @ordergroups.joins(:orders).where(:orders => {:starts.gte => Time.now.months_ago(3)}) if params[:only_active] # Select only active groups

    @total = @ordergroups.size
    @ordergroups = @ordergroups.paginate(:page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :layout => false }
    end
  end
end
