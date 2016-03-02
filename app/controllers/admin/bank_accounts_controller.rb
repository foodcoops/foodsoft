class Admin::BankAccountsController < Admin::BaseController
  inherit_resources

  def index
    @bank_accounts = BankAccount.order('name')
  end

  def create
    create!(:notice => I18n.t('admin.bank_accounts.create.notice')) { admin_bank_accounts_path }
  end

  def update
    update!(:notice => I18n.t('admin.bank_accounts.update.notice')) { admin_bank_accounts_path }
  end

  def destroy
    @bank_account = BankAccount.find(params[:id])
    @bank_account.destroy
    redirect_to admin_bank_accounts_path, notice: t('admin.bank_accounts.destroy.notice')
  rescue => error
    redirect_to admin_bank_accounts_path, alert: t('admin.bank_accounts.destroy.error', error: error.message)
  end
end
