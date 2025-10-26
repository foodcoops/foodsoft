class Api::V1::User::FinancialTransactionsController < Api::BaseController
  include Concerns::CollectionScope

  before_action -> { doorkeeper_authorize! 'finance:user' }
  before_action :require_ordergroup
  before_action :require_minimum_balance, only: [:create]
  before_action -> { require_config_enabled :use_self_service }, only: [:create]

  def index
    render_collection search_scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  def create
    transaction_type = FinancialTransactionType.find(create_params[:financial_transaction_type_id])
    ft = current_ordergroup.add_financial_transaction!(create_params[:amount], create_params[:note], current_user,
                                                       transaction_type)
    render json: ft
  end

  private

  def scope
    current_ordergroup.financial_transactions.includes(:user, :financial_transaction_type)
  end

  def include_incomple?
    params.permit(:include_incomplete)[:include_incomplete]
  end

  def search_scope
    scope = super
    include_incomple? ? scope : scope.where.not(amount: nil)
  end

  def create_params
    params.require(:financial_transaction).permit(:amount, :financial_transaction_type_id, :note)
  end
end
