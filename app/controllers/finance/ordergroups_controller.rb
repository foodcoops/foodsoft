class Finance::OrdergroupsController < Finance::BaseController

  def index
    if params["sort"]
      sort = case params["sort"]
               when "name" then "name"
               when "account_balance" then "account_balance"
               when "name_reverse" then "name DESC"
               when "account_balance_reverse" then "account_balance DESC"
               when "available_funds" then "available_funds"
               when "available_funds_reverse" then "available_funds DESC"
             end
    else
      sort = "name"
    end

    @ordergroups = Ordergroup.undeleted.order(sort)
    @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%") unless params[:query].nil?
    @ordergroups = @ordergroups.select("*, (SELECT COALESCE(SUM(price),0) FROM group_orders INNER JOIN orders WHERE group_orders.order_id=orders.id AND group_orders.ordergroup_id=groups.id AND orders.state IN ('open', 'finished')) AS available_funds")

    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)
  end
end
