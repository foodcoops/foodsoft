require 'swagger_helper'

describe 'Users API', type: :request do
  include ApiHelper

  path '/user' do
    get 'info about the currently logged-in user' do
      tags 'User'
      produces 'application/json'
      let(:api_scopes) { ['user:read'] }
      let(:other_user_1) { create :user }
      let(:user)         { create :user }
      let(:other_user_2) { create :user }

      response '200', 'success' do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user']['id']).to eq(user.id)
        end
      end

      it_handles_invalid_token_and_scope
    end
  end

  path '/user/financial_overview' do
    get 'financial summary about the currently logged-in user' do
      tags 'User', 'FinancialTransaction'
      let!(:user) { create :user, :ordergroup }

      response 200, 'success' do
        let(:api_scopes) { ['finance:user'] }
        run_test!
      end

      it_handles_invalid_token_and_scope
    end
  end
end
