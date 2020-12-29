# encoding: utf-8
class Admin::OrdergroupsController < Admin::BaseController
  inherit_resources

  def index
    @ordergroups = Ordergroup.undeleted.order('name ASC')

    # Place it before the CSV stuff to enable exporting filtered data by directly
    # constructing the URL
    # .../ordergroups.csv?query_unpaid=QUERY
    #
    unless params[:query_unpaid].blank?
      @ordergroups = @ordergroups.joins(:payments).where(payments: {name: "#{params[:query_unpaid]}"})
      # invert
      @ordergroups = Ordergroup.where.not(:id => @ordergroups.reorder("groups.name").pluck(:id))
    end

    if request.format.csv?
      send_data OrdergroupsCsv.new(@ordergroups).to_csv, filename: 'ordergroups.csv', type: 'text/csv'
    end

    # if somebody uses the search field:
    unless params[:query].blank?
      @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%")
    end

    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)
  end

  def destroy
    @ordergroup = Ordergroup.find(params[:id])
    @ordergroup.mark_as_deleted
    redirect_to admin_ordergroups_url, notice: t('admin.ordergroups.destroy.notice')
  rescue => error
    redirect_to admin_ordergroups_url, alert: t('admin.ordergroups.destroy.error')
  end
end
