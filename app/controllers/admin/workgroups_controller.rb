class Admin::WorkgroupsController < Admin::BaseController
  inherit_resources

  def index
    @workgroups = Workgroup.order(:name.asc)
    # if somebody uses the search field:
    @workgroups = @workgroups.where(:name.matches => "%#{params[:query]}%") unless params[:query].blank?

    @workgroups = @workgroups.paginate(:page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.haml
      format.js { render :layout => false } # index.js.erb
    end
  end

  def memberships
    @group = Workgroup.find(params[:id])
  end
end
