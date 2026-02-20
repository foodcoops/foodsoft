require 'swagger_helper'

shared_context 'with OrderArticlesController api v1' do
  include ApiHelper

  path '/order_articles' do
    get 'order articles' do
      tags 'Order'
      produces 'application/json'
      pagination_param
      q_ordered_url_param

      let(:api_scopes) { ['orders:read', 'orders:write'] }
      let(:order) { create(:order, article_count: 4) }
      let(:order_articles) { order.order_articles }

      before do
        order_articles[0].update! quantity: 0, tolerance: 0, units_to_order: 0
        order_articles[1].update! quantity: 1, tolerance: 0, units_to_order: 0
        order_articles[2].update! quantity: 0, tolerance: 1, units_to_order: 0
        order_articles[3].update! quantity: 0, tolerance: 0, units_to_order: 1
      end

      response '200', 'success' do
        schema type: :object, properties: {
          meta: { '$ref' => '#/components/schemas/Meta' },
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

        describe 'when ordered by supplier' do
          let(:q) { { q: { ordered: 'supplier' } } }

          run_test! do |response|
            json_order_articles = JSON.parse(response.body)['order_articles']
            json_order_article_ids = json_order_articles.map { |d| d['id'].to_i }
            expect(json_order_article_ids).to contain_exactly(order_articles[3].id)
          end
        end

        describe 'when ordered by member' do
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
      id_url_param
      let(:api_scopes) { ['orders:read', 'orders:write'] }

      response '200', 'success' do
        schema type: :object, properties: {
          order_article: {
            '$ref': '#/components/schemas/OrderArticle'
          }
        }
        let(:order) { create(:order, article_count: 1) }
        let(:id) { order.order_articles.first.id }

        run_test!
      end

      it_handles_invalid_token_and_scope
      it_cannot_find_object 'order article not found'
    end
  end
end
