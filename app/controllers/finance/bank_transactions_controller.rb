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
    @bank_transactions_all = @bank_account.bank_transactions.order(sort).includes(:financial_link)
    @bank_transactions_all = @bank_transactions_all.where('reference LIKE ? OR text LIKE ?', "%#{params[:query]}%", "%#{params[:query]}%") unless params[:query].nil?
    @bank_transactions = @bank_transactions_all.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.js; format.html { render }
      format.csv do
        send_data BankTransactionsCsv.new(@bank_transactions_all).to_csv, filename: 'transactions.csv', type: 'text/csv'
      end
    end
  end

  def show
    @bank_transaction = BankTransaction.find(params[:id])
  end
end
