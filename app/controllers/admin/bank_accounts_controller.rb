class Admin::BankAccountsController < Admin::BaseController
  inherit_resources

  def new
    @bank_account = BankAccount.new(params[:bank_account])
    render :layout => false
  end

  def create
    @bank_account = BankAccount.new(params[:bank_account])
    if @bank_account.valid? && @bank_account.save
      redirect_to update_bank_accounts_admin_finances_url, :status => 303
    else
      render :action => 'new', :layout => false
    end
  end

  def edit
    @bank_account = BankAccount.find(params[:id])
    render :action => 'new', :layout => false
  end

  def update
    @bank_account = BankAccount.find(params[:id])

    if @bank_account.update(params[:bank_account])
      redirect_to update_bank_accounts_admin_finances_url, :status => 303
    else
      render :action => 'new', :layout => false
    end
  end

  def destroy
    @bank_account = BankAccount.find(params[:id])
    @bank_account.destroy
    redirect_to update_bank_accounts_admin_finances_url, :status => 303
  rescue => error
    flash.now[:alert] = error.message
    render template: 'shared/alert'
  end
end
