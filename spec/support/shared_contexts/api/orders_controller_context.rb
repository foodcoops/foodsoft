require 'swagger_helper'

shared_context 'with OrdersController api v1' do
  include ApiHelper

  let(:api_scopes) { ['orders:read'] }

  path '/orders' do
    get 'orders' do
      tags 'Order'
      produces 'application/json'
      pagination_param
      let(:order) { create(:order) }

      response '200', 'success' do
        schema type: :object, properties: {
          meta: { '$ref' => '#/components/schemas/Meta' },
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
      id_url_param

      let(:order) { create(:order) }

      response '200', 'success' do
        schema type: :object, properties: {
          order: { '$ref' => '#/components/schemas/Order' }
        }
        let(:id) { order.id }

        run_test! do |response|
          expect(JSON.parse(response.body)['order']['id']).to eq order.id
        end
      end

      it_handles_invalid_token_and_scope
      it_cannot_find_object 'order not found'
    end
  end
end
