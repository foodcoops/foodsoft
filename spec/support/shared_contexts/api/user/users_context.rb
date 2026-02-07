require 'swagger_helper'

shared_context 'with User::UsersController api v1' do
  include ApiHelper

  path '/user' do
    get 'info about the currently logged-in user' do
      tags 'User'
      produces 'application/json'
      let(:api_scopes) { ['user:read'] }
      let(:other_user1) { create(:user) }
      let(:user) { create(:user) }
      let(:other_user2) { create(:user) }

      response '200', 'success' do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: {
                       type: :integer
                     },
                     name: {
                       type: :string,
                       description: 'full name'
                     },
                     email: {
                       type: :string,
                       description: 'email address'
                     },
                     locale: {
                       type: :string,
                       description: 'language code'
                     }
                   },
                   required: %w[id name email]
                 }
               }

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
      tags 'User', 'Financial Transaction'
      produces 'application/json'
      let(:user) { create(:user, :ordergroup) }
      let(:api_scopes) { ['finance:user'] }
      FinancialTransactionClass.create(name: 'TestTransaction')

      response 200, 'success' do
        schema type: :object,
               properties: {
                 financial_overview: {
                   type: :object,
                   properties: {

                     account_balance: {
                       type: :number,
                       description: 'booked accout balance of ordergroup'
                     },
                     available_funds: {
                       type: :number,
                       description: 'fund available to order articles'
                     },
                     financial_transaction_class_sums: {
                       type: :array,
                       properties: {
                         id: {
                           type: :integer,
                           description: 'id of the financial transaction class'
                         },
                         name: {
                           type: :string,
                           description: 'name of the financial transaction class'
                         },
                         amount: {
                           type: :number,
                           description: 'sum of the amounts belonging to the financial transaction class'
                         }
                       },
                       required: %w[id name amount]
                     }
                   },
                   required: %w[account_balance available_funds financial_transaction_class_sums]
                 }
               }

        run_test!
      end

      it_handles_invalid_token_and_scope
    end
  end
end
