class Foodcoop::OrdergroupsController < ApplicationController
  
  def index
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end

    if (params[:only_active].to_i == 1)
      if (! params[:query].blank?)
        conditions = ["orders.starts >= ? AND name LIKE ?", Time.now.months_ago(3), "%#{params[:query]}%"]
      else
        conditions = ["orders.starts >= ?", Time.now.months_ago(3)]
      end
    else
      # if somebody uses the search field:
      conditions = ["name LIKE ?", "%#{params[:query]}%"] unless params[:query].blank?
    end

    @total = Ordergroup.count(:conditions => conditions, :include => "orders")
    @ordergroups = Ordergroup.paginate(:page => params[:page], :per_page => @per_page, :conditions => conditions, :order => "name", :include => "orders")

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => "ordergroups" }
    end
  end
end
