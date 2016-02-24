class Admin::FinancialTransactionTypesController < Admin::BaseController
  inherit_resources

  def index
    @financial_transaction_types = FinancialTransactionType.order('name ASC')
  end

  def destroy
    @financial_transaction_type = FinancialTransactionClass.find(params[:id])
    @financial_transaction_type.destroy
    redirect_to admin_financial_transaction_types_url, notice: t('admin.financial_transaction_types.destroy.notice')
  rescue => error
    redirect_to admin_financial_transaction_types_url, alert: t('admin.financial_transaction_types.destroy.error', error: error.message)
  end
end
