require 'swagger_helper'

describe Api::V2::FinancialTransactionsController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with FinancialTransactionsController api v1'
end
