require 'swagger_helper'

describe Api::V2::OrderArticlesController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with OrderArticlesController api v1'
end
