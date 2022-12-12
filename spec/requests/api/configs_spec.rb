require 'swagger_helper'

describe 'Config', type: :request do
  include ApiHelper

  path '/config' do
    get 'configuration variables' do
      tags 'General'
      produces 'application/json'
      let(:api_scopes) { ['config:user'] }

      response '200', 'success' do
        schema type: :object, properties: {}
        run_test!
      end

      it_handles_invalid_token_and_scope
    end
  end
end
