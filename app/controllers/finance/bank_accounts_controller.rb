class Finance::BankAccountsController < Finance::BaseController

  def index
    @bank_accounts = BankAccount.order('name')
    redirect_to finance_bank_account_transactions_url(@bank_accounts.first) if @bank_accounts.count == 1
  end

  def import
    @bank_account = BankAccount.find(params[:id])
    import_method = @bank_account.find_import_method
    if import_method
      count = import_method.call(@bank_account)
      redirect_to finance_bank_account_transactions_url(@bank_account), notice: t('finance.bank_accounts.controller.import.notice', :count => count)
    end
  rescue => error
    redirect_to finance_bank_account_transactions_url(@bank_account), :alert => I18n.t('errors.general_msg', :msg => error.message)
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
