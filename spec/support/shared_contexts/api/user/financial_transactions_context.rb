require 'swagger_helper'

shared_context 'with User::FinancialTransactionsController api v1' do
  include ApiHelper

  let(:api_scopes) { ['finance:user'] }
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:other_user2) { create(:user) }
  let!(:financial_transaction) { create(:financial_transaction, user: user, ordergroup: user.ordergroup) }
  let!(:financial_transaction_amount_nil) { create(:financial_transaction, user: user, ordergroup: user.ordergroup, amount: nil) }

  path '/user/financial_transactions' do
    post 'create new financial transaction (requires enabled self service)' do
      tags 'Financial Transaction'
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

      let(:financial_transaction) do
        { amount: 3, financial_transaction_type_id: create(:financial_transaction_type).id, note: 'lirum larum' }
      end

      response '200', 'success' do
        schema type: :object, properties: {
          financial_transaction: { '$ref': '#/components/schemas/FinancialTransaction' }
        }
        run_test!
      end

      it_handles_invalid_token_with_id
      it_handles_invalid_scope_with_id 'user has no ordergroup, is below minimum balance, self service is disabled, or missing scope'

      response '404', 'financial transaction type not found' do
        schema '$ref' => '#/components/schemas/Error404'
        let(:financial_transaction) { { amount: 3, financial_transaction_type_id: 'invalid', note: 'lirum larum' } }
        run_test!
      end

      response '422', 'invalid parameter value' do
        schema '$ref' => '#/components/schemas/Error422'
        let(:financial_transaction) do
          { amount: 'abc', financial_transaction_type_id: create(:financial_transaction_type).id, note: 'foo bar' }
        end
        run_test!
      end
    end

    get "financial transactions of the member's ordergroup" do
      tags 'User', 'Financial Transaction'
      produces 'application/json'
      pagination_param
      parameter name: :include_incomplete, in: :query, type: :boolean, required: false

      get_properties = {
        meta: { '$ref': '#/components/schemas/Meta' },
        financial_transaction: {
          type: :array,
          items: {
            '$ref': '#/components/schemas/FinancialTransaction'
          }
        }
      }

      response '200', 'success' do
        schema type: :object, properties: get_properties
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['meta']['total_count']).to eq 1
          expect(data['financial_transactions'].first['id']).to eq(financial_transaction.id)
        end
      end

      response '200', 'success' do # with incomplete transactions
        schema type: :object, properties: get_properties
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

  path '/user/financial_transactions/{id}' do
    get 'find financial transaction by id' do
      tags 'User', 'Financial Transaction'
      produces 'application/json'
      id_url_param

      response '200', 'success' do
        schema type: :object, properties: {
          financial_transaction: {
            '$ref': '#/components/schemas/FinancialTransaction'
          }
        }
        let(:id) { financial_transaction.id }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['financial_transaction']['id']).to eq(financial_transaction.id)
        end
      end

      it_handles_invalid_token_with_id
      it_handles_invalid_scope_with_id 'user has no ordergroup or missing scope'
      it_cannot_find_object 'financial transaction not found'
    end
  end
end
