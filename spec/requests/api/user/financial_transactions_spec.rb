require 'swagger_helper'

describe 'User', type: :request do
  include ApiHelper

  let(:api_scopes) { ['finance:user'] }
  let(:user) { create :user, groups: [create(:ordergroup)] }
  let(:other_user2) { create :user }
  let(:ft) { create(:financial_transaction, user: user, ordergroup: user.ordergroup) }

  before do
    ft
  end

  path '/user/financial_transactions' do
    post 'financial transaction to create' do
      tags 'User', 'FinancialTransaction'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :financial_transaction, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :integer },
          financial_transaction_type: { type: :integer },
          note: { type: :string }
        }
      }
      let(:financial_transaction) { { amount: 3, financial_transaction_type_id: create(:financial_transaction_type).id, note: 'lirum larum' } }

      response '200', 'success' do
        schema type: :object, properties: {
          financial_transaction_for_create: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionForCreate'
            }
          }
        }
        run_test!
      end

      # 401
      it_handles_invalid_token_with_id(:financial_transaction)

      # 403
      # description: user has no ordergroup, is below minimum balance, self service is disabled, or missing scope
      it_handles_invalid_scope_with_id(:financial_transaction)

      # TODO: fix 404 and 422
      # 404
      # Type not found
      # description: financial transaction type not found
      # Should be 404, but is 200 with validation errors..
      #      Rswag::Specs::UnexpectedResponse:
      #  Expected response code '404' to match '200'
      #  Response body: {"error":"not_found","error_description":"Couldn't find FinancialTransactionType with 'id'=invalid"}
      # let(:financial_transaction) { { amount: 3, financial_transaction_type_id: 'invalid', note: 'lirum larum' } }
      # response '404', 'invalid parameter value' do
      #  schema '$ref' => '#/components/schemas/Error404'
      #  run_test!
      # end

      # 422
      # response '422', 'invalid parameter value' do
      #   let(:financial_transaction) { { amount: -3, financial_transaction_type_id: create(:financial_transaction_type).id, note: -2 } }

      #   schema '$ref' => '#/components/schemas/Error422'
      #   run_test!
      # end

    end

    get 'financial transactions of the members ordergroup' do
      tags 'User', 'Financial Transaction'
      produces 'application/json'

      response '200', 'success' do
        schema type: :object, properties: {
          meta: {
            type: :object,
            items:
            {
              '$ref': '#/components/schemas/Meta'
            }
          },
          financial_transaction: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['financial_transactions'].first['id']).to eq(ft.id)
        end
      end
      # responses 401 & 403
      it_handles_invalid_token_and_scope
    end
  end

  path '/user/financial_transactions/{id}' do
    get 'find financial transaction by id' do
      tags 'User', 'FinancialTransaction'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'success' do
        schema type: :object, properties: {
          financial_transaction: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }
        let(:id) { ft.id }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['financial_transaction']['id']).to eq(ft.id)
        end
      end

      # 401
      it_handles_invalid_token_with_id(:financial_transaction)
      # 403
      it_handles_invalid_scope_with_id(:financial_transaction)
      # 404
      response '404', 'financial transaction not found' do
        schema type: :object, properties: {
          financial_transaction: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
