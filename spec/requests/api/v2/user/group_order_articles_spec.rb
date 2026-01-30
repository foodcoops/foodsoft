require 'swagger_helper'

describe Api::V2::User::GroupOrderArticlesController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with User::GroupOrderArticlesController api v1'
end
