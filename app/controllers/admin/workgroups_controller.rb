# encoding: utf-8
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

  def destroy
    @workgroup = Workgroup.find(params[:id])
    @workgroup.destroy
    redirect_to admin_workgroups_url, :notice => "Arbeitsgruppe wurde gelöscht"
  rescue => error
    redirect_to admin_workgroups_url, :alert => "Arbeitsgruppe konnte nicht gelöscht werden: #{error}"
  end
end
