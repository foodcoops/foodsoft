class Finance::BankAccountsController < Finance::BaseController

  def index
    @bank_accounts = BankAccount.order('name')
    redirect_to finance_bank_account_transactions_url(@bank_accounts.first) if @bank_accounts.count == 1
  end

end
