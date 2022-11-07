require 'swagger_helper'

describe 'Users API', type: :request do
  path '/user' do
    get 'info about the currently logged-in user' do
      tags '1. User'
      produces 'application/json'

      response '200', 'success' do
        run_test! do |response|
          let(:Authorization) { "Basic #{::Base64.strict_encode64('jsmith:jspass')}" }
          data = JSON.parse(response.body)
          # expect(data[])
        end
      end

      response '401', 'not logged-in' do
        run_test!
      end
    end
  end
end
