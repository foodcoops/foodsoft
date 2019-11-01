class Finance::BaseController < ApplicationController
  before_action :authenticate_finance

  def index
    @financial_transactions = FinancialTransaction.with_ordergroup.includes(:ordergroup).order(created_on: :desc).limit(8)
    @orders = Order.finished_not_closed.includes(:supplier).limit(8)
    @unpaid_invoices = Invoice.unpaid.includes(:supplier).limit(8)

    render template: 'finance/index'
  end

  def new_report; end

  def create_report
    date_start = params[:report][:date_start].to_date
    date_end = params[:report][:date_end].to_date
    pdf = FinanceReport.new date_start...date_end
    send_data pdf.to_pdf, filename: pdf.filename, type: 'application/pdf', disposition: :inline
  end
end
