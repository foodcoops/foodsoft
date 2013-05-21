class Finance::BaseController < ApplicationController
  before_filter :authenticate_finance

  def index
    @financial_transactions = FinancialTransaction.order('created_on DESC').limit(8)
    @orders = Order.finished_not_closed
    @unpaid_invoices = Invoice.unpaid

    render template: 'finance/index'
  end
end