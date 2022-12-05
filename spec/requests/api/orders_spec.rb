require 'swagger_helper'

describe 'Orders', type: :request do
  include ApiHelper
  let(:api_scopes) { ['orders:read'] }

  path '/orders' do
    get 'orders' do
      tags 'Order'
      produces 'application/json'
      parameter name: "per_page", in: :query, type: :integer, required: false
      parameter name: "page", in: :query, type: :integer, required: false
      let(:page) { 1 }
      let(:per_page) { 20 }

      let(:order) { create(:order) }

      response '200', 'success' do
        schema type: :object, properties: {
          meta: {
            '$ref' => '#/components/schemas/Meta'
          },
          ordes: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/Order'
            }
          }
        }

        run_test!
      end

      it_handles_invalid_token_and_scope
    end
  end

  path '/orders/{id}' do
    get 'Order' do
      tags 'Order'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :integer, minimum: 1, required: true
      let(:order) { create(:order) }
      let(:id) { order.id }

      response '200', 'success' do
        schema type: :object, properties: {
          '$ref': '#/components/schemas/Order'
        }

        run_test! do |response|
          expect(JSON.parse(response.body)['order']['id']).to eq order.id
        end
      end
    end
  end
end
