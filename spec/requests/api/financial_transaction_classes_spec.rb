require 'swagger_helper'

describe 'Financial Transaction Classes', type: :request do
  include ApiHelper

  path '/financial_transaction_classes' do
    get 'financial transaction classes' do
      tags 'Category'
      produces 'application/json'

      parameter name: "per_page", in: :query, type: :integer, required: false
      parameter name: "page", in: :query, type: :integer, required: false
      let(:page) { 1 }
      let(:per_page) { 10 }

      let(:financial_transaction_class) { create(:financial_transaction_class) }

      response '200', 'success' do
        schema type: :object, properties: {
          financial_transaction_class: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionClass'
            }
          }
        }

        run_test!
      end

      it_handles_invalid_token
    end
  end

  path '/financial_transaction_classes/{id}' do
    get 'Retrieves a financial transaction class' do
      tags 'Category'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'financial transaction class found' do
        schema type: :object, properties: {
          financial_transaction_classes: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionClass'
            }
          }
        }
        let(:id) { FinancialTransactionClass.create(name: 'TestTransaction').id }
        run_test!
      end

      response '401', 'not logged in' do
        schema type: :object, properties: {
          financial_transaction_classes: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionClass'
            }
          }
        }
        let(:Authorization) { 'abc' }
        let(:id) { FinancialTransactionClass.create(name: 'TestTransaction').id }
        run_test!
      end

      response '404', 'financial transaction class not found' do
        schema type: :object, properties: {
          financial_transaction_classes: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionClass'
            }
          }
        }
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
