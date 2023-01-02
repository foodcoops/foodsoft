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
      pagination_param

      response '200', 'success' do
        schema type: :object, properties: {
          meta: { '$ref' => '#/components/schemas/Meta' },
          financial_transaction: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }

        run_test!
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
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }
        let(:id) { FinancialTransaction.create(user: user).id }
        run_test!
      end
      it_handles_invalid_token_with_id
      it_handles_invalid_scope_with_id
      it_cannot_find_object 'financial transaction not found'
    end
  end
end
