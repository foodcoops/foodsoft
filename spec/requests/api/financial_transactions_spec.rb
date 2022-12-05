require 'swagger_helper'

describe 'Financial Transaction', type: :request do
  include ApiHelper
  let!(:finance_user) { create(:user, groups: [create(:workgroup, role_finance: true)]) }
  let!(:api_scopes) { ['finance:read', 'finance:write'] }
  let(:api_access_token) { create(:oauth2_access_token, resource_owner_id: finance_user.id, scopes: api_scopes&.join(' ')).token }
  let(:financial_transaction) { create(:financial_transaction, user: user) }

  path '/financial_transactions' do
    get 'financial transactions' do
      tags 'Financial Transaction'
      produces 'application/json'
      parameter name: "per_page", in: :query, type: :integer, required: false
      parameter name: "page", in: :query, type: :integer, required: false

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
        let(:page) { 1 }
        let(:per_page) { 10 }
        run_test!
      end
      it_handles_invalid_scope
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
      it_handles_invalid_scope_with_id(:financial_transaction, 'missing scope or no permission')

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
      # response 403
      it_handles_invalid_scope_with_id(:financial_transaction, 'missing scope or no permission')
    end
  end
end
