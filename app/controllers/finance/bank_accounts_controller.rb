class Finance::BankAccountsController < Finance::BaseController

  def index
    @bank_accounts = BankAccount.order('name')
    redirect_to finance_bank_account_transactions_url(@bank_accounts.first) if @bank_accounts.count == 1
  end

  def assign_unlinked_transactions
    @bank_account = BankAccount.find(params[:id])
    count = @bank_account.assign_unlinked_transactions
    redirect_to finance_bank_account_transactions_url(@bank_account), notice: t('finance.bank_accounts.controller.assign.notice', count: count)
  rescue => error
    redirect_to finance_bank_account_transactions_url(@bank_account), alert: t('errors.general_msg', msg: error.message)
  end

  def import
    @bank_account = BankAccount.find(params[:id])
    import_method = @bank_account.find_import_method
    if import_method
      count = import_method.call(@bank_account)
      redirect_to finance_bank_account_transactions_url(@bank_account), notice: t('finance.bank_accounts.controller.import.notice', count: count)
    else
      # @todo add import for csv files as fallback
      redirect_to finance_bank_account_transactions_url(@bank_account), alert: t('finance.bank_accounts.controller.import.no_import_method')
    end
  rescue => error
    redirect_to finance_bank_account_transactions_url(@bank_account), alert: t('errors.general_msg', msg: error.message)
  end

end
