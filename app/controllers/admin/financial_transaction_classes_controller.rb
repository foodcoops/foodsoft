class Admin::FinancialTransactionClassesController < Admin::BaseController
  inherit_resources

  def new
    @financial_transaction_class = FinancialTransactionClass.new(params[:financial_transaction_class])
    render layout: false
  end

  def create
    @financial_transaction_class = FinancialTransactionClass.new(params[:financial_transaction_class])
    if @financial_transaction_class.save
      redirect_to update_transaction_types_admin_finances_url, status: 303
    else
      render action: 'new', layout: false
    end
  end

  def edit
    @financial_transaction_class = FinancialTransactionClass.find(params[:id])
    render action: 'new', layout: false
  end

  def update
    @financial_transaction_class = FinancialTransactionClass.find(params[:id])

    if @financial_transaction_class.update(params[:financial_transaction_class])
      redirect_to update_transaction_types_admin_finances_url, status: 303
    else
      render action: 'new', layout: false
    end
  end

  def destroy
    @financial_transaction_class = FinancialTransactionClass.find(params[:id])
    @financial_transaction_class.destroy!
    redirect_to update_transaction_types_admin_finances_url, status: 303
  rescue => error
    flash.now[:alert] = error.message
    render template: 'shared/alert'
  end
end
