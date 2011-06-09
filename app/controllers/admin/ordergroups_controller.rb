class Admin::OrdergroupsController < Admin::BaseController
  inherit_resources
  
  def index
    @ordergroups = Ordergroup.order(:name.asc)

    # if somebody uses the search field:
    unless params[:query].blank?
      @ordergroups = @ordergroups.where(:name.matches => "%#{params[:query]}%")
    end

    # sort by nick, thats default
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end

    @ordergroups = @ordergroups.paginate(:page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.haml
      format.js { render :layout => false } # index.js.erb
    end
  end

  def memberships
    @group = Ordergroup.find(params[:id])
  end
end
