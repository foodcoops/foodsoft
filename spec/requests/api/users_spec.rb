require 'swagger_helper'

describe 'Users API', type: :request do
  path '/user' do
    get 'info about the currently logged-in user' do
      # security [oauth2: []]
      tags '1. User'
      produces 'application/json'
      let(:user) { create(:user) }
      let(:api_access_token) { create(:oauth2_access_token, resource_owner_id: user.id, scopes: api_scopes&.join(' ')).token }
      let(:Authorization) { "Bearer #{api_access_token}" }

      response '200', 'success' do
        let(:api_scopes) { ['user:read'] }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user']['id']).to eq(user.id)
        end
      end

      response '403', 'missing scope' do
        let(:api_scopes) { [] }
        run_test!
      end


      response '401', 'not logged-in' do
        let(:Authorization) { "" }
        run_test!
      end
    end
  end
end
