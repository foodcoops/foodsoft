class Finance::BankTransactionsController < ApplicationController
  before_action :authenticate_finance
  inherit_resources

  def index
    if params["sort"]
      sort = case params["sort"]
               when "date" then "date"
               when "amount" then "amount"
               when "financial_link" then "financial_link_id"
               when "date_reverse" then "date DESC"
               when "amount_reverse" then "amount DESC"
               when "financial_link_reverse" then "financial_link_id DESC"
             end
    else
      sort = "date DESC"
    end

    @bank_account = BankAccount.find(params[:bank_account_id])
    @bank_transactions = @bank_account.bank_transactions.order(sort).includes(:financial_link)
    @bank_transactions = @bank_transactions.where('reference LIKE ? OR text LIKE ?', "%#{params[:query]}%", "%#{params[:query]}%") unless params[:query].nil?
    @bank_transactions = @bank_transactions.page(params[:page]).per(@per_page)
  end

  def show
    @bank_transaction = BankTransaction.find(params[:id])
  end
end
