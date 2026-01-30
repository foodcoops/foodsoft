require 'swagger_helper'

describe Api::V2::FinancialTransactionClassesController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with FinancialTransactionClassesController api v1'
end
