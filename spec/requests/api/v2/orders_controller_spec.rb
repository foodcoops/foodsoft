require 'swagger_helper'

describe Api::V2::OrdersController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with OrdersController api v1'
end
