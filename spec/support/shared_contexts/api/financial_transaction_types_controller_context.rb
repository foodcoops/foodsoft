require 'swagger_helper'

shared_context 'with FinancialTransactionTypesController api v1' do
  include ApiHelper

  path '/financial_transaction_types' do
    get 'financial transaction types' do
      tags 'Category'
      produces 'application/json'
      pagination_param
      let(:financial_transaction_type) { create(:financial_transaction_type) }
      response '200', 'success' do
        schema type: :object, properties: {
          meta: { '$ref' => '#/components/schemas/Meta' },
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
      id_url_param

      response '200', 'financial transaction type found' do
        schema type: :object, properties: {
          financial_transaction_types: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionType'
            }
          }
        }
        let(:id) { create(:financial_transaction_type).id }
        run_test!
      end

      it_handles_invalid_token_with_id
      it_cannot_find_object 'financial transaction type not found'
    end
  end
end
