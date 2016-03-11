class Api::V1::FinancialTransactionsController < Api::V1::BaseController
  def index
    ordergroup = current_user.ordergroup
    ft = ordergroup ? ordergroup.financial_transactions.map { |t| t.id } : []
    render json: ft
  end

  def show
    ft = FinancialTransaction.find_by! id: params[:id], ordergroup: current_user.ordergroup
    render json: {
      user: ft.user.display,
      amount: ft.amount.to_f,
      note: ft.note
    }
  end
end
