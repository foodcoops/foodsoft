require 'swagger_helper'

shared_context 'with User::GroupOrderArticlesController api v1' do
  include ApiHelper

  let(:api_scopes) { ['group_orders:user'] }
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:other_user2) { create(:user) }
  let(:order) { create(:order, article_count: 4) }
  let(:order_articles) { order.order_articles }
  let(:group_order) { create(:group_order, ordergroup: user.ordergroup, order_id: order.id) }
  let(:goa) { create(:group_order_article, group_order: group_order, order_article: order_articles.first) }

  before do
    goa
  end

  path '/user/group_order_articles' do
    get 'group order articles' do
      tags 'User', 'Order'
      produces 'application/json'
      pagination_param
      q_ordered_url_param

      response '200', 'success' do
        schema type: :object, properties: {
          meta: { '$ref': '#/components/schemas/Meta' },
          group_order_article: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/GroupOrderArticle'
            }
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['group_order_articles'].first['id']).to eq(goa.id)
        end
      end

      it_handles_invalid_token
      it_handles_invalid_scope 'user has no ordergroup or missing scope'
    end

    post 'create new group order article' do
      tags 'User', 'Order'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :group_order_article, in: :body,
                description: 'group order article to create',
                required: true,
                schema: { '$ref': '#/components/schemas/GroupOrderArticleForCreate' }

      let(:group_order_article) { { order_article_id: order_articles.last.id, quantity: 1, tolerance: 2 } }
      response '200', 'success' do
        schema type: :object, properties: {
          group_order_article: {
            '$ref': '#/components/schemas/GroupOrderArticle'
          },
          order_article: {
            '$ref': '#/components/schemas/OrderArticle'
          }
        }
        run_test!
      end

      it_handles_invalid_token_with_id
      it_handles_invalid_scope_with_id 'user has no ordergroup, order not open, is below minimum balance, has not enough apple points, or missing scope'

      response '404', 'order article not found in open orders' do
        let(:group_order_article) { { order_article_id: 'invalid', quantity: 1, tolerance: 2 } }
        schema '$ref' => '#/components/schemas/Error404'
        run_test!
      end

      response '422', 'invalid parameter value or group order article already exists' do
        let(:group_order_article) { { order_article_id: goa.order_article_id, quantity: 1, tolerance: 2 } }
        schema '$ref' => '#/components/schemas/Error422'
        run_test!
      end
    end
  end

  path '/user/group_order_articles/{id}' do
    get 'find group order article by id' do
      tags 'User', 'Order'
      produces 'application/json'
      id_url_param

      response '200', 'success' do
        schema type: :object, properties: {
          group_order_article: {
            '$ref': '#/components/schemas/GroupOrderArticle'
          },
          order_article: {
            '$ref': '#/components/schemas/OrderArticle'
          }
        }

        let(:id) { goa.id }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['group_order_article']['id']).to eq(goa.id)
        end
      end

      it_handles_invalid_scope_with_id
      it_handles_invalid_token_with_id
      it_cannot_find_object 'group order article not found'
    end

    patch 'update a group order article (but delete if quantity and tolerance are zero)' do
      tags 'User', 'Order'
      consumes 'application/json'
      produces 'application/json'
      id_url_param
      parameter name: :group_order_article, in: :body,
                description: 'group order article update',
                required: true,
                schema: { '$ref': '#/components/schemas/GroupOrderArticleForUpdate' }

      let(:id) { goa.id }
      let(:group_order_article) { { order_article_id: goa.order_article_id, quantity: 2, tolerance: 2 } }

      response '200', 'success' do
        schema type: :object, properties: {
          group_order_article: {
            '$ref': '#/components/schemas/GroupOrderArticle'
          }
        }
        run_test!
      end

      response 401, 'not logged-in' do
        schema '$ref' => '#/components/schemas/Error401'
        let(:Authorization) { 'abc' } # rubocop:disable  RSpec/VariableName
        run_test!
      end

      response 403,
               'user has no ordergroup, order not open, is below minimum balance, has not enough apple points, or missing scope' do
        let(:api_scopes) { ['none'] }
        schema '$ref' => '#/components/schemas/Error403'
        run_test!
      end

      response '404', 'order article not found in open orders' do
        schema type: :object, properties: {
          group_order_article: {
            '$ref': '#/components/schemas/GroupOrderArticle'
          }
        }
        let(:id) { 'invalid' }
        run_test!
      end

      response '422', 'invalid parameter value' do
        let(:group_order_article) { { order_article_id: 'invalid', quantity: -5, tolerance: 'invalid' } }
        schema '$ref' => '#/components/schemas/Error422'
        run_test!
      end
    end

    delete 'remove group order article' do
      tags 'User', 'Order'
      consumes 'application/json'
      produces 'application/json'
      id_url_param
      let(:api_scopes) { ['group_orders:user'] }

      response '200', 'success' do
        schema type: :object, properties: {
          group_order_article: {
            '$ref': '#/components/schemas/GroupOrderArticle'
          }
        }
        let(:id) { goa.id }
        run_test!
      end

      it_handles_invalid_token_with_id

      response 403,
               'user has no ordergroup, order not open, is below minimum balance, has not enough apple points, or missing scope' do
        let(:api_scopes) { ['none'] }
        schema '$ref' => '#/components/schemas/Error403'
        run_test!
      end

      it_cannot_find_object 'order article not found in open orders'
    end
  end
end
