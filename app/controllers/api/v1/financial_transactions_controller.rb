class Api::V1::FinancialTransactionsController < Api::V1::BaseController

  before_action :require_ordergroup

  def index
    ft = current_ordergroup.financial_transactions.map { |t| t.id }
    render json: ft
  end

  def show
    ft = FinancialTransaction.find_by! id: params.require(:id), ordergroup: current_ordergroup
    render json: {
      user: show_user(ft.user),
      amount: ft.amount.to_f,
      note: ft.note
    }
  end

end
