class Admin::FinancesController < Admin::BaseController
  inherit_resources

  def index
    @bank_accounts = BankAccount.order('name')
    @financial_transaction_classes = FinancialTransactionClass.includes(:financial_transaction_types).order('name ASC')
  end

  def update_bank_accounts
    @bank_accounts = BankAccount.order('name')
    render :layout => false
  end

  def update_transaction_types
    @financial_transaction_classes = FinancialTransactionClass.includes(:financial_transaction_types).order('name ASC')
    render :layout => false
  end

end
