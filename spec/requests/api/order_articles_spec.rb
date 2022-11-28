require 'swagger_helper'

describe 'Order Articles', type: :request do
  include ApiHelper

  path '/order_articles' do
    get 'order articles' do
      tags 'Order'
      produces 'application/json'
      parameter name: 'page[number]', in: :query, type: :integer, required: false
      parameter name: 'page[size]', in: :query, type: :integer, required: false
      parameter name: 'q', in: :query, required: false,
                description: "'member' show articles ordered by the user's ordergroup, 'all' by all members, and 'supplier' ordered at the supplier",
                schema: {
                  type: :object,
                  ordered: {
                    type: :string,
                    enum: %w[member all supplier]
                  }
                }
      let(:api_scopes) { ['orders:read', 'orders:write'] }
      let(:order) { create(:order, article_count: 4) }
      let(:order_articles) { order.order_articles }

      before do
        order_articles[0].update_attributes! quantity: 0, tolerance: 0, units_to_order: 0
        order_articles[1].update_attributes! quantity: 1, tolerance: 0, units_to_order: 0
        order_articles[2].update_attributes! quantity: 0, tolerance: 1, units_to_order: 0
        order_articles[3].update_attributes! quantity: 0, tolerance: 0, units_to_order: 1
      end

      response '200', 'success' do
        schema type: :object, properties: {
          meta: {
            '$ref' => '#/components/schemas/Meta'
          },
          order_articles: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/OrderArticle'
            }
          }
        }
        describe '(unset)' do
          run_test!
        end

        describe 'all' do
          let(:q) { { q: { ordered: 'all' } } }

          run_test! do |response|
            json_order_articles = JSON.parse(response.body)['order_articles']
            json_order_article_ids = json_order_articles.map { |d| d['id'].to_i }
            expect(json_order_article_ids).to match_array order_articles[1..2].map(&:id)
          end
        end

        describe 'supplier' do
          let(:q) { { q: { ordered: 'supplier' } } }

          run_test! do |response|
            json_order_articles = JSON.parse(response.body)['order_articles']
            json_order_article_ids = json_order_articles.map { |d| d['id'].to_i }
            expect(json_order_article_ids).to match_array [order_articles[3].id]
          end
        end

        describe 'member' do
          let(:q) { { q: { ordered: 'member' } } }

          run_test! do |response|
            json_order_articles = JSON.parse(response.body)['order_articles']
            expect(json_order_articles.count).to eq 0
          end
        end

        context 'when ordered by user' do
          let(:user) { create(:user, :ordergroup) }
          let(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }

          before do
            create(:group_order_article, group_order: go, order_article: order_articles[1], quantity: 1)
            create(:group_order_article, group_order: go, order_article: order_articles[2], tolerance: 0)
          end

          describe 'member' do
            let(:q) { { q: { ordered: 'member' } } }

            run_test! do |response|
              json_order_articles = JSON.parse(response.body)['order_articles']
              json_order_article_ids = json_order_articles.map { |d| d['id'].to_i }
              expect(json_order_article_ids).to match_array order_articles[1..2].map(&:id)
            end
          end
        end
      end

      it_handles_invalid_token_and_scope
    end
  end

  path '/order_articles/{id}' do
    get 'order articles' do
      tags 'Order'
      produces 'application/json'
      parameter name: 'id', in: :path, type: :integer, minimum: 1, required: true

      let(:api_scopes) { ['orders:read', 'orders:write'] }
      let(:order) { create(:order, article_count: 1) }
      let(:id) { order.order_articles.first.id }

      response '200', 'success' do
        schema type: :object, properties: {
          order_article: {
            '$ref': '#/components/schemas/OrderArticle'
          }
        }

        run_test!
      end

      it_handles_invalid_token_and_scope
    end
  end
end
