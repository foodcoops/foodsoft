class Finance::BankAccountsController < Finance::BaseController

  def index
    @bank_accounts = BankAccount.order('name')
  end

  def import
    @bank_account = BankAccount.find(params[:id])
  end

  def parse_upload
    @bank_account = BankAccount.find(params[:id])
    uploaded_file = params[:bank_accounts]['file'] or raise I18n.t('bank_accounts.controller.parse_upload.no_file')
    options = {extension: File.extname(uploaded_file.original_filename)}
    count = @bank_account.import_from_file uploaded_file.tempfile, options
    redirect_to finance_bank_account_transactions_url(@bank_account), :notice => I18n.t('bank_accounts.controller.parse_upload.notice', :count => count)
  rescue => error
    redirect_to import_finance_bank_account_url(@bank_account), :alert => I18n.t('errors.general_msg', :msg => error.message)
  end
end
