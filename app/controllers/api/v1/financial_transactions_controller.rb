class Api::V1::FinancialTransactionsController < Api::BaseController
  include Concerns::CollectionScope

  before_action -> { doorkeeper_authorize! 'finance:read', 'finance:write' }

  def index
    render_collection search_scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def scope
    FinancialTransaction.includes(:user, :financial_transaction_type)
  end

  def include_incomple?
    params.permit(:include_incomplete)[:include_incomplete] == 'true'
  end

  def search_scope
    scope = super
    include_incomple? ? scope : scope.where.not(amount: nil)
  end

  def ransack_auth_object
    :finance
  end
end
