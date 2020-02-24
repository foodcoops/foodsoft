class Finance::BankAccountsController < Finance::BaseController

  def index
    @bank_accounts = BankAccount.order('name')
    redirect_to finance_bank_account_transactions_url(@bank_accounts.first) if @bank_accounts.count == 1
  end

  def assign_unlinked_transactions
    @bank_account = BankAccount.find(params[:id])
    count = @bank_account.assign_unlinked_transactions
    redirect_to finance_bank_account_transactions_url(@bank_account), notice: t('.notice', count: count)
  rescue => error
    redirect_to finance_bank_account_transactions_url(@bank_account), alert: t('errors.general_msg', msg: error.message)
  end

  def import
    @bank_account = BankAccount.find(params[:id])
    importer = @bank_account.find_connector

    if importer
      importer.load params[:state] && YAML.load(params[:state])

      ok = importer.import params[:controls]

      importer.finish if ok
      flash.notice = t('.notice', count: importer.count) if ok
      @auto_submit = importer.auto_submit
      @controls = importer.controls
      #TODO: encrypt state
      @state = YAML.dump importer.dump
    else
      ok = true
      flash.alert = t('.no_import_method')
    end

    needs_redirect = ok
  rescue => error
    flash.alert = t('errors.general_msg', msg: error.message)
    needs_redirect = true
  ensure
    return unless needs_redirect
    redirect_path = finance_bank_account_transactions_url(@bank_account)
    if request.post?
      @js_redirect = redirect_path
    else
      redirect_to redirect_path
    end
  end

end
