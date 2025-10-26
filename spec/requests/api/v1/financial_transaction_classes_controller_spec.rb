require 'swagger_helper'

describe Api::V1::FinancialTransactionClassesController do
  include ApiHelper

  it_behaves_like 'with FinancialTransactionClassesController api v1'
end
