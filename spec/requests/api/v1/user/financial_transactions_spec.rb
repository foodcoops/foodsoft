require 'swagger_helper'

describe Api::V1::User::FinancialTransactionsController do
  include ApiHelper

  it_behaves_like 'with User::FinancialTransactionsController api v1'
end
