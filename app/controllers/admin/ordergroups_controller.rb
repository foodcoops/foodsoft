class Admin::OrdergroupsController < Admin::BaseController
  inherit_resources

  def index
    @ordergroups = Ordergroup.undeleted.sort_by_param(params['sort'])

    if request.format.csv?
      send_data OrdergroupsCsv.new(@ordergroups).to_csv, filename: 'ordergroups.csv',
                                                         type: 'text/csv'
    end

    # if somebody uses the search field:
    @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%") if params[:query].present?

    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)
  end

  def destroy
    @ordergroup = Ordergroup.find(params[:id])
    @ordergroup.mark_as_deleted
    redirect_to admin_ordergroups_url, notice: t('.notice')
  rescue StandardError => e
    redirect_to admin_ordergroups_url, alert: t('.error')
  end
end
