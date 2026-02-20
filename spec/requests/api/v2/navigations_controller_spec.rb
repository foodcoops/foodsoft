require 'swagger_helper'

describe Api::V2::NavigationsController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with NavigationsController api v1'
end
