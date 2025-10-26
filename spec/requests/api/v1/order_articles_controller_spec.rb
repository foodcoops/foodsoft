require 'swagger_helper'

describe Api::V1::OrderArticlesController do
  include ApiHelper

  it_behaves_like 'with OrderArticlesController api v1'
end
