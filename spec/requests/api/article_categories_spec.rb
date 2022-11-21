require 'swagger_helper'

describe 'Article Categories', type: :request do
  include ApiHelper

  path '/article_categories' do
    get 'article categories' do
      tags 'Category'
      produces 'application/json'
      parameter name: :page, in: :query, schema: { '$ref' => '#/components/schemas/page' }
      parameter name: :per_page, in: :query, schema: { '$ref' => '#/components/schemas/per_page' }

      let(:api_scopes) { ['orders:read'] }
      let!(:order_article) { create(:order, article_count: 1).order_articles.first }
      let!(:stock_article) { create(:stock_article) }
      let!(:stock_order_article) { create(:stock_order, article_ids: [stock_article.id]).order_articles.first }


      response '200', 'success' do
        schema type: :object, properties: {
          article_categories: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/ArticleCategory'
            }
          },
          meta: {
            '$ref': '#/components/schemas/Meta'
          }
        }

        let(:page) { 0 }
        let(:per_page) { 20 }
        run_test!
      end

      it_handles_invalid_token_and_scope
    end
  end
end
