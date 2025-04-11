class Api::V1::FinancialTransactionsController < Api::V1::BaseController
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

  def ransack_auth_object
    :finance
  end
end
