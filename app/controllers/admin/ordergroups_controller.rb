class Admin::OrdergroupsController < Admin::BaseController
  inherit_resources
  
  def index
    @ordergroups = Ordergroup.order(:name.asc)

    # if somebody uses the search field:
    unless params[:query].blank?
      @ordergroups = @ordergroups.where(:name.matches => "%#{params[:query]}%")
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
