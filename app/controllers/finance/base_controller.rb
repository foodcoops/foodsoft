class Finance::BaseController < ApplicationController
  before_action :authenticate_finance

  def index
    @financial_transactions = FinancialTransaction.includes(:ordergroup).order('created_on DESC').limit(8)
    @orders = Order.finished_not_closed.includes(:supplier)
    @unpaid_invoices = Invoice.unpaid.includes(:supplier)

    render template: 'finance/index'
  end
end
