require 'swagger_helper'

describe Api::V1::ConfigsController do
  include ApiHelper

  it_behaves_like 'with ConfigsController api v1'
end
