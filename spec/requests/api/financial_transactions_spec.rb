require 'swagger_helper'

describe 'Financial Transaction', type: :request do
  include ApiHelper

  path '/financial_transactions' do
    get 'financial transactions' do
      tags 'Financial Transaction'
      produces 'application/json'
      parameter name: "page[number]", in: :query, type: :integer, required: false
      parameter name: "page[size]", in: :query, type: :integer, required: false

      let!(:financial_transaction) { create(:financial_transaction) }
      let(:api_scopes) { ['finance:read', 'finance:write'] }

      response '200', 'success' do
        schema type: :object, properties: {
          meta: {
            '$ref' => '#/components/schemas/pagination'
          },
          financial_transaction: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }

        let(:page) { { number: 1, size: 20 } }
        run_test!
      end

      it_handles_invalid_token
    end
  end

  path '/financial_transactions/{id}' do
    get 'Retrieves a financial transaction ' do
      tags 'Category'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'financial transaction found' do
        schema type: :object, properties: {
          financial_transaction: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }
        let(:id) { FinancialTransaction.create(user: user).id }
        run_test!
      end

      response '401', 'not logged in' do
        schema type: :object, properties: {
          financial_transaction: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }
        let(:Authorization) { 'abc' }
        let(:id) { FinancialTransaction.create(name: 'TestTransaction').id }
        run_test!
      end

      response '404', 'financial transaction not found' do
        schema type: :object, properties: {
          financial_transaction: {
            type: :array,
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
