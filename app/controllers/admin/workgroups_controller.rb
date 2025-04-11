class Admin::WorkgroupsController < Admin::BaseController
  inherit_resources

  def index
    @workgroups = Workgroup.order('name ASC')
    # if somebody uses the search field:
    @workgroups = @workgroups.where('name LIKE ?', "%#{params[:query]}%") if params[:query].present?

    @workgroups = @workgroups.page(params[:page]).per(@per_page)
  end

  def destroy
    @workgroup = Workgroup.find(params[:id])
    @workgroup.destroy
    redirect_to admin_workgroups_url, notice: t('.notice')
  rescue StandardError => e
    redirect_to admin_workgroups_url, alert: t('.error', error: e.message)
  end
end
