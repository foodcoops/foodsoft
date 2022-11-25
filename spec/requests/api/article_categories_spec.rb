require 'swagger_helper'

describe 'Article Categories', type: :request do
  include ApiHelper

  path '/article_categories' do
    get 'article categories' do
      tags 'Category'
      produces 'application/json'
      parameter name: "page[number]", in: :query, type: :integer, required: false
      parameter name: "page[size]", in: :query, type: :integer, required: false

      let!(:order_article) { create(:order, article_count: 1).order_articles.first }
      let!(:stock_article) { create(:stock_article) }
      let!(:stock_order_article) { create(:stock_order, article_ids: [stock_article.id]).order_articles.first }

      response '200', 'success' do
        schema type: :object, properties: {
          meta: {
            '$ref' => '#/components/schemas/pagination'
          },
          article_categories: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/ArticleCategory'
            }
          }
        }

        let(:page) { { number: 1, size: 20 } }
        run_test!
      end

      it_handles_invalid_token
    end
  end

  path '/article_categories/{id}' do
    get 'Retrieves an article category' do
      tags 'Category'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response '200', 'article category found' do
        schema type: :object, properties: {
          article_categories: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/ArticleCategory'
            }
          }
        }
        let(:id) { ArticleCategory.create(name: 'dairy').id }
        run_test!
      end

      response '401', 'not logged in' do
        schema type: :object, properties: {
          article_categories: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/ArticleCategory'
            }
          }
        }
        let(:Authorization) { 'abc' }
        let(:id) { ArticleCategory.create(name: 'dairy').id }
        run_test!
      end

      response '404', 'article category not found' do
        schema type: :object, properties: {
          article_categories: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/ArticleCategory'
            }
          }
        }
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end