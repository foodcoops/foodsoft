class Api::V1::FinancialTransactionTypesController < Api::V1::BaseController
  include Concerns::CollectionScope

  def index
    render json: search_scope
  end

  def show
    render json: scope.find(params.require(:id))
  end

  private

  def max_per_page
    nil
  end

  def default_per_page
    nil
  end

  def scope
    FinancialTransactionType.includes(:bank_account, :financial_transaction_class)
  end
end
