require 'swagger_helper'

describe 'Financial Transaction types', type: :request do
  include ApiHelper

  path '/financial_transaction_types' do
    get 'financial transaction types' do
      tags 'Category'
      produces 'application/json'
      parameter name: "per_page", in: :query, type: :integer, required: false
      parameter name: "page", in: :query, type: :integer, required: false
      let(:page) { 1 }
      let(:per_page) { 10 }
      let(:financial_transaction_type) { create(:financial_transaction_type) }
      response '200', 'success' do
        schema type: :object, properties: {
          financial_transaction_type: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionType'
            }
          }
        }
        run_test!
      end

      it_handles_invalid_token
    end
  end

  path '/financial_transaction_types/{id}' do
    get 'find financial transaction type by id' do
      tags 'Category'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'financial transaction type found' do
        schema type: :object, properties: {
          financial_transaction_types: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionType'
            }
          }
        }
        let(:id) { FinancialTransactionType.create(name: 'TestType').id }
        run_test!
      end

      response '401', 'not logged in' do
        schema type: :object, properties: {
          financial_transaction_types: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionType'
            }
          }
        }
        let(:Authorization) { 'abc' }
        let(:id) { FinancialTransactionType.create(name: 'TestType').id }
        run_test!
      end

      response '404', 'financial transaction type not found' do
        schema type: :object, properties: {
          financial_transaction_types: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionType'
            }
          }
        }
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
