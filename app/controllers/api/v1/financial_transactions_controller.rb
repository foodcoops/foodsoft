class Api::V1::FinancialTransactionsController < Api::V1::BaseController
  include Concerns::CollectionScope

  before_action :require_ordergroup

  def index
    render_collection search_scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def scope
    current_ordergroup.financial_transactions
  end

end
