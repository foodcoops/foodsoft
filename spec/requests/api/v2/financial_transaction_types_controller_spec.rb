require 'swagger_helper'

describe Api::V2::FinancialTransactionTypesController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with FinancialTransactionTypesController api v1'
end
