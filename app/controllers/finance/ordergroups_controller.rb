class Finance::OrdergroupsController < Finance::BaseController

  def index
    if params["sort"]
      sort = case params["sort"]
               when "name" then "name"
               when "account_balance" then "account_balance"
               when "name_reverse" then "name DESC"
               when "account_balance_reverse" then "account_balance DESC"
             end
    else
      sort = "name"
    end

    @ordergroups = Ordergroup.undeleted.order(sort)
    @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%") unless params[:query].nil?

    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)
  end
end
