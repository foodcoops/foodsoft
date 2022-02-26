class Admin::OrdergroupsController < Admin::BaseController
  inherit_resources

  def index
    sort = if params["sort"]
             case params["sort"]
             when "name" then "name"
             when "name_reverse" then "name DESC"
             when "last_user_activity" then "users.last_activity"
             when "last_user_activity_reverse" then "users.last_activity DESC"
             when "last_order" then "max(orders.starts)"
             when "last_order_reverse" then "max(orders.starts) DESC"
             end
           else
             "name"
           end

    case params["sort"]
    when "last_user_activity", "last_user_activity_reverse" then @ordergroups = Ordergroup.left_joins(:users).undeleted.order(sort).distinct
    when "last_order", "last_order_reverse" then @ordergroups = Ordergroup.left_joins(:orders).group("groups.id").undeleted.order(sort).distinct
    else
      @ordergroups = Ordergroup.undeleted.order(sort)
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
