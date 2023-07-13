class Finance::OrdergroupsController < Finance::BaseController
  def index
    m = /^(?<col>name|sum_of_class_\d+)(?<reverse>_reverse)?$/.match params['sort']
    if m
      sort = m[:col]
      sort += ' DESC' if m[:reverse]
    else
      sort = 'name'
    end

    @ordergroups = Ordergroup.undeleted.order(sort)
    @ordergroups = @ordergroups.include_transaction_class_sum
    @ordergroups = @ordergroups.where('groups.name LIKE ?', "%#{params[:query]}%") unless params[:query].nil?
    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)

    @total_balances = FinancialTransactionClass.sorted.each_with_object({}) do |c, tmp|
      tmp[c.id] = c.financial_transactions.reduce(0) { |sum, t| sum + t.amount }
    end
  end
end
