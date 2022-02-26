class Admin::BankGatewaysController < Admin::BaseController
  inherit_resources

  def new
    @bank_gateway = BankGateway.new(params[:bank_gateway])
    render layout: false
  end

  def create
    @bank_gateway = BankGateway.new(params[:bank_gateway])
    if @bank_gateway.valid? && @bank_gateway.save
      redirect_to update_bank_gateways_admin_finances_url, status: :see_other
    else
      render action: 'new', layout: false
    end
  end

  def edit
    @bank_gateway = BankGateway.find(params[:id])
    render action: 'new', layout: false
  end

  def update
    @bank_gateway = BankGateway.find(params[:id])

    if @bank_gateway.update(params[:bank_gateway])
      redirect_to update_bank_gateways_admin_finances_url, status: :see_other
    else
      render action: 'new', layout: false
    end
  end

  def destroy
    @bank_gateway = BankGateway.find(params[:id])
    @bank_gateway.destroy
    redirect_to update_bank_gateways_admin_finances_url, status: :see_other
  rescue StandardError => e
    flash.now[:alert] = e.message
    render template: 'shared/alert'
  end
end
