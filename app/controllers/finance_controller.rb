class FinanceController < ApplicationController
  before_filter :authenticate_finance

  def index
    @financial_transactions = FinancialTransaction.find(:all, :order => "created_on DESC", :limit => 8)
    @orders = Order.find(:all, :conditions => 'finished = 1 AND booked = 0', :order => 'ends DESC')
    @unpaid_invoices = Invoice.unpaid
  end
  
end