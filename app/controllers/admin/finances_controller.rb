class Admin::FinancesController < Admin::BaseController
  inherit_resources

  def index
    @bank_accounts = BankAccount.order('name')
    @bank_gateways = BankGateway.order('name')
    @financial_transaction_classes = FinancialTransactionClass.includes(:financial_transaction_types).order('name ASC')
    @supplier_categories = SupplierCategory.order('name')
  end

  def update_bank_accounts
    @bank_accounts = BankAccount.order('name')
    render :layout => false
  end

  def update_bank_gateways
    @bank_gateways = BankGateway.order('name')
    render :layout => false
  end

  def update_transaction_types
    @financial_transaction_classes = FinancialTransactionClass.includes(:financial_transaction_types).order('name ASC')
    render :layout => false
  end

  def update_supplier_categories
    @supplier_categories = SupplierCategory.order('name')
    render :layout => false
  end
end
