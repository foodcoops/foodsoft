require 'swagger_helper'

describe Api::V1::ArticleCategoriesController do
  include ApiHelper

  it_behaves_like 'with ArticleCategoriesController api v1'
end
