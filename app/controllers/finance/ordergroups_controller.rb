class Finance::OrdergroupsController < ApplicationController
  before_filter :authenticate_finance
  
  def index
    if params["sort"]
      sort = case params["sort"]
               when "name" then "name"
               when "account_balance" then "account_balance"
               when "name_reverse" then "name DESC"
               when "account_balance_reverse" then "account_balance DESC"
             end
    else
      sort = "name"
    end

    @ordergroups = Ordergroup.order(sort)
    @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%") unless params[:query].nil?

    @ordergroups = @ordergroups.paginate :page => params[:page], :per_page => @per_page

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
end
