class Finance::BaseController < ApplicationController
  before_action :authenticate_finance

  def index
    @financial_transactions = FinancialTransaction.with_ordergroup.includes(:ordergroup).order(created_on: :desc).limit(8)
    @orders = Order.finished_not_closed.includes(:supplier).limit(8)
    @unpaid_invoices = Invoice.unpaid.includes(:supplier).limit(8)

    render template: 'finance/index'
  end
end
