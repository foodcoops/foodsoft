require 'swagger_helper'

describe Api::V1::User::UsersController do
  include ApiHelper

  it_behaves_like 'with User::UsersController api v1'
end
