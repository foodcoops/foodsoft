require 'swagger_helper'

describe Api::V2::User::UsersController, swagger_doc: 'v2/swagger.yaml' do
  include ApiHelper

  it_behaves_like 'with User::UsersController api v1'
end
