class Api::V1::User::OrdergroupController < Api::BaseController
  before_action -> { doorkeeper_authorize! 'finance:user' }, only: [:financial_overview]

  def financial_overview
    ordergroup = Ordergroup.include_transaction_class_sum.find(current_ordergroup.id)

    render json: {
      financial_overview: {
        account_balance: ordergroup.account_balance.to_f,
        available_funds: ordergroup.get_available_funds.to_f,
        financial_transaction_class_sums: FinancialTransactionClass.sorted.map do |c|
          {
            id: c.id,
            name: c.display,
            amount: ordergroup["sum_of_class_#{c.id}"].to_f
          }
        end
      }
    }
  end
end
