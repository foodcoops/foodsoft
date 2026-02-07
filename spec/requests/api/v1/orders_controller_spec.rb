require 'swagger_helper'

describe Api::V1::OrdersController do
  include ApiHelper

  it_behaves_like 'with OrdersController api v1'
end
