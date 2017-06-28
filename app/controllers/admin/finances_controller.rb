class Admin::FinancesController < Admin::BaseController
  inherit_resources

  def index
    @financial_transaction_classes = FinancialTransactionClass.order('name ASC')
  end

  def update_transaction_types
    @financial_transaction_classes = FinancialTransactionClass.order('name ASC')
    render :layout => false
  end

end
