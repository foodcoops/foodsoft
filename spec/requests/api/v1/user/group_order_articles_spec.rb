require 'swagger_helper'

describe Api::V1::User::GroupOrderArticlesController do
  include ApiHelper

  it_behaves_like 'with User::GroupOrderArticlesController api v1'
end
