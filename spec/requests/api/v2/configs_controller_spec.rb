require 'swagger_helper'

describe Api::V2::ConfigsController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with ConfigsController api v1'
end
