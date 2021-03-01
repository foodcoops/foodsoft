class Admin::MessagegroupsController < Admin::BaseController
  inherit_resources

  def index
    @messagegroups = Messagegroup.order('name ASC')
    # if somebody uses the search field:
    @messagegroups = @messagegroups.where('name LIKE ?', "%#{params[:query]}%") unless params[:query].blank?

    @messagegroups = @messagegroups.page(params[:page]).per(@per_page)
  end

  def destroy
    @messagegroup = Messagegroup.find(params[:id])
    @messagegroup.destroy
    redirect_to admin_messagegroups_url, notice: t('admin.messagegroups.destroy.notice')
  rescue => error
    redirect_to admin_messagegroups_url, alert: t('admin.messagegroups.destroy.error', error: error.message)
  end
end
