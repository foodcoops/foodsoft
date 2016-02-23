class Finance::BankTransactionsController < ApplicationController
  before_filter :authenticate_finance
  inherit_resources

  def index
    if params["sort"]
      sort = case params["sort"]
               when "booking_date" then "booking_date"
               when "amount" then "amount"
               when "booking_date_reverse" then "booking_date DESC"
               when "amount_reverse" then "amount DESC"
             end
    else
      sort = "import_id DESC"
    end

    @bank_account = BankAccount.find(params[:bank_account_id])
    @bank_transactions = BankTransaction.order(sort)
    @bank_transactions = @bank_transactions.where('reference LIKE ? OR text LIKE ?', "%#{params[:query]}%", "%#{params[:query]}%") unless params[:query].nil?
    @bank_transactions = @bank_transactions.page(params[:page]).per(@per_page)
  end

  def show
    @bank_transaction = BankTransaction.find(params[:id])
  end
end
