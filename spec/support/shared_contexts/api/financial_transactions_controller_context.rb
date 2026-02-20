require 'swagger_helper'

shared_context 'with FinancialTransactionsController api v1' do
  include ApiHelper

  let!(:finance_user) { create(:user, groups: [create(:workgroup, role_finance: true)]) }
  let!(:api_scopes) { ['finance:read', 'finance:write'] }
  let(:api_access_token) do
    create(:oauth2_access_token, resource_owner_id: finance_user.id, scopes: api_scopes&.join(' ')).token
  end
  let!(:financial_transaction) { create(:financial_transaction, user: user) }
  let!(:financial_transaction_amount_nil) { create(:financial_transaction, user: user, amount: nil, payment_amount: 42) }

  path '/financial_transactions' do
    get 'financial transactions' do
      tags 'Financial Transaction'
      produces 'application/json'
      pagination_param
      parameter name: :include_incomplete, in: :query, type: :boolean, required: false
      properties = {
        meta: { '$ref' => '#/components/schemas/Meta' },
        financial_transaction: {
          type: :array,
          items: {
            '$ref': '#/components/schemas/FinancialTransaction'
          }
        }
      }

      response '200', 'success' do
        schema type: :object, properties: properties
        run_test! do |response|
          expect(JSON.parse(response.body)['meta']['total_count']).to eq 1
        end
      end

      response '200', 'success' do # with incomplete transactions
        schema type: :object, properties: properties
        let(:include_incomplete) { true }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['meta']['total_count']).to eq 2
          expect(data['financial_transactions'].pluck('id')).to include(financial_transaction_amount_nil.id)
        end
      end

      it_handles_invalid_token_and_scope
    end
  end

  path '/financial_transactions/{id}' do
    get 'Retrieves a financial transaction ' do
      tags 'Financial Transaction'
      produces 'application/json'
      id_url_param

      response '200', 'financial transaction found' do
        schema type: :object, properties: {
          financial_transaction: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }
        let(:id) { financial_transaction.id }
        run_test! do |response|
          expect(JSON.parse(response.body)['financial_transaction']['id']).to eq id
        end
      end
      it_handles_invalid_token_with_id
      it_handles_invalid_scope_with_id
      it_cannot_find_object 'financial transaction not found'
    end
  end
end
