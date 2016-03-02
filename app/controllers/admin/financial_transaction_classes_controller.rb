class Admin::FinancialTransactionClassesController < Admin::BaseController
  inherit_resources

  def index
    @financial_transaction_classes = FinancialTransactionClass.order('name ASC')
  end

  def destroy
    @financial_transaction_class = FinancialTransactionClass.find(params[:id])
    @financial_transaction_class.destroy
    redirect_to admin_financial_transaction_classes_url, notice: t('admin.financial_transaction_classes.destroy.notice')
  rescue => error
    redirect_to admin_financial_transaction_classes_url, alert: t('admin.financial_transaction_classes.destroy.error', error: error.message)
  end
end
