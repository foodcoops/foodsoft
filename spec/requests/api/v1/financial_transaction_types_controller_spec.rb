require 'swagger_helper'

describe Api::V1::FinancialTransactionTypesController do
  include ApiHelper

  it_behaves_like 'with FinancialTransactionTypesController api v1'
end
