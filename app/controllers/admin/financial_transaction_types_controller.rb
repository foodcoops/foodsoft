class Admin::FinancialTransactionTypesController < Admin::BaseController
  inherit_resources

  def new
    @financial_transaction_type = FinancialTransactionType.new(params[:financial_transaction_type])
    @financial_transaction_type.financial_transaction_class = FinancialTransactionClass.find_by_id(params[:financial_transaction_class]) if params[:financial_transaction_class]
    render layout: false
  end

  def create
    @financial_transaction_type = FinancialTransactionType.new(params[:financial_transaction_type])
    if @financial_transaction_type.save
      redirect_to update_transaction_types_admin_finances_url, status: 303
    else
      render action: 'new', layout: false
    end
  end

  def edit
    @financial_transaction_type = FinancialTransactionType.find(params[:id])
    render action: 'new', layout: false
  end

  def update
    @financial_transaction_type = FinancialTransactionType.find(params[:id])

    if @financial_transaction_type.update(params[:financial_transaction_type])
      redirect_to update_transaction_types_admin_finances_url, status: 303
    else
      render action: 'new', layout: false
    end
  end

  def destroy
    @financial_transaction_type = FinancialTransactionType.find(params[:id])
    @financial_transaction_type.destroy!
    redirect_to update_transaction_types_admin_finances_url, status: 303
  rescue => error
    flash.now[:alert] = error.message
    render template: 'shared/alert'
  end
end
