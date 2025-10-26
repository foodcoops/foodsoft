require 'swagger_helper'

describe Api::V2::ArticleCategoriesController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with ArticleCategoriesController api v1'
end
