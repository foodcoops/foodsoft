class Finance::BankGatewaysController < Finance::BaseController
  before_action :find_bank_gateway

  def callback
    bank_account = params[:bank_account]
    redirect_to_url = bank_account ? finance_bank_account_transactions_url(bank_account) : unpaid_finance_invoices_path

    count = @bank_gateway.connector.handle_callback params
    @bank_gateway.bank_accounts.each(&:assign_unlinked_transactions) unless bank_account

    redirect_to redirect_to_url, notice: t('.notice', count: count)
  rescue => error
    redirect_to redirect_to_url, alert: t('errors.general_msg', msg: error.message)
  end

  def import
    bank_account = params[:bank_account]
    callback_uri = url_for(action: :callback, only_path: false, bank_account: bank_account)
    reconfigure = params[:reconfigure]
    user = @bank_gateway.unattended_user ? nil : current_user
    return deny_access if reconfigure && !@bank_gateway.can_reconfigure?(current_user)

    location = @bank_gateway.connector.pay_and_import_url callback_uri, user, nil, reconfigure: reconfigure
    redirect_to location, status: :found
  rescue => error
    redirect_to finance_bank_account_transactions_url(bank_account), alert: t('errors.general_msg', msg: error.message)
  end

  private

  def find_bank_gateway
    @bank_gateway = BankGateway.find(params[:id])
  end
end
