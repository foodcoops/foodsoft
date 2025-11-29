require 'swagger_helper'

describe Api::V1::NavigationsController do
  include ApiHelper

  it_behaves_like 'with NavigationsController api v1'
end
