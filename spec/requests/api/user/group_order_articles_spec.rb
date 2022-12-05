require 'swagger_helper'

describe 'User', type: :request do
  include ApiHelper

  let(:api_scopes) { ['group_orders:user'] }
  let(:user) { create :user, groups: [create(:ordergroup)] }
  let(:other_user2) { create :user }
  let(:order) { create(:order, article_count: 4) }
  let(:order_articles) { order.order_articles }
  let(:group_order) { create :group_order, ordergroup: user.ordergroup, order_id: order.id }
  let(:goa) { create :group_order_article, group_order: group_order, order_article: order_articles.first }

  before do
    goa
  end

  path '/user/group_order_articles' do
    get 'group order articles' do
      tags 'User', 'Order'
      produces 'application/json'
      parameter name: "per_page", in: :query, type: :integer, required: false
      parameter name: "page", in: :query, type: :integer, required: false
      let(:page) { 1 }
      let(:per_page) { 20 }
      response '200', 'success' do
        schema type: :object, properties: {
          meta: {
            type: :object,
            items:
            {
              '$ref': '#/components/schemas/Meta'
            }
          },
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

      # response 401
      it_handles_invalid_token

      # response 403
      it_handles_invalid_scope('user has no ordergroup or missing scope')
    end
    post 'create new group order article' do
      tags 'User', 'Order'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :group_order_article, in: :body, schema: {
        type: :object,
        description: 'group order article to create',
        properties: {
          order_article_id: { type: :integer },
          quantity: { type: :integer },
          tolerance: { type: :string }
        },
        required: true
      }

      let(:group_order_article) { { order_article_id: order_articles.last.id, quantity: 1, tolerance: 2 } }
      response '200', 'success' do
        schema type: :object, properties: {
          group_order_article_for_create: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/GroupOrderArticleForCreate'
            }
          }
        }
        run_test!
      end

      # 401
      it_handles_invalid_token_with_id(:group_order_article)

      # 403
      # description: user has no ordergroup, is below minimum balance, self service is disabled, or missing scope
      it_handles_invalid_scope_with_id(:group_order_article, 'user has no ordergroup, order not open, is below minimum balance, has not enough apple points, or missing scope')

      # 404
      response '404', 'order article not found in open orders' do
        let(:group_order_article) { { order_article_id: 'invalid', quantity: 1, tolerance: 2 } }
        schema '$ref' => '#/components/schemas/Error404'
        run_test!
      end

      # 422
      response '422', 'invalid parameter value or group order article already exists' do
        let(:group_order_article) { { order_article_id: goa.order_article_id, quantity: 1, tolerance: 2 } }
        schema '$ref' => '#/components/schemas/Error422'
        run_test!
      end
    end
  end

  path '/user/group_order_articles/{id}' do
    get 'find group order article by id' do
      tags 'User', 'GroupOrderArticle'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      let(:id) { goa.id }
      response '200', 'success' do
        schema type: :object, properties: {
          group_order_article: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/GroupOrderArticle'
            }
          }
        }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['group_order_article']['id']).to eq(goa.id)
        end
      end

      # 401
      response 401, 'not logged-in' do
        let(:Authorization) { 'abc' }
        schema '$ref' => '#/components/schemas/Error401'
        run_test!
      end
      # 403
      response 403, 'user has no ordergroup or missing scope' do
        let(:api_scopes) { ['none'] }
        schema '$ref' => '#/components/schemas/Error403'
        run_test!
      end
      # 404
      response '404', 'group order article not found' do
        schema type: :object, properties: {
          group_order_article: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/GroupOrderArticle'
            }
          }
        }
        let(:id) { 'invalid' }
        run_test!
      end
    end
    patch 'update a group order article (but delete if quantity and tolerance are zero)' do
      tags 'User', 'GroupOrderArticle'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      parameter name: :group_order_article, in: :body, schema: {
        type: :object,
        description: 'group order article to create',
        properties: {
          order_article_id: { type: :integer },
          quantity: { type: :integer },
          tolerance: { type: :string }
        },
        required: true
      }
      let(:id) { goa.id }
      let(:group_order_article) { { order_article_id: goa.order_article_id, quantity: 2, tolerance: 2 } }

      response '200', 'success' do
        schema type: :object, properties: {
          group_order_article_for_create: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/GroupOrderArticleForUpdate'
            }
          }
        }
        run_test!
      end
      # 401
      response 401, 'not logged-in' do
        let(:Authorization) { 'abc' }
        schema '$ref' => '#/components/schemas/Error401'
        run_test!
      end
      # 403
      response 403, 'user has no ordergroup, order not open, is below minimum balance, has not enough apple points, or missing scope' do
        let(:api_scopes) { ['none'] }
        schema '$ref' => '#/components/schemas/Error403'
        run_test!
      end
      # 404
      response '404', 'order article not found in open orders' do
        schema type: :object, properties: {
          group_order_article: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/GroupOrderArticle'
            }
          }
        }
        let(:id) { 'invalid' }
        run_test!
      end

      # 422
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
      let(:api_scopes) { ['group_orders:user'] }

      parameter name: :id, in: :path, type: :string

      let(:id) { goa.id }
      response '200', 'success' do
        schema type: :object, properties: {
          group_order_article: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/GroupOrderArticle'
            }
          }
        }
        run_test!
      end

      # 401
      response 401, 'not logged-in' do
        let(:Authorization) { 'abc' }
        schema '$ref' => '#/components/schemas/Error401'
        run_test!
      end

      # 403
      response 403, 'user has no ordergroup, order not open, is below minimum balance, has not enough apple points, or missing scope' do
        let(:api_scopes) { ['none'] }
        schema '$ref' => '#/components/schemas/Error403'
        run_test!
      end

      # 404
      it_cannot_find_object('order article not found in open orders')
    end
  end
end
