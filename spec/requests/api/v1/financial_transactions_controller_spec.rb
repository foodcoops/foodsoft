require 'swagger_helper'

describe Api::V1::FinancialTransactionsController do
  include ApiHelper

  it_behaves_like 'with FinancialTransactionsController api v1'
end
