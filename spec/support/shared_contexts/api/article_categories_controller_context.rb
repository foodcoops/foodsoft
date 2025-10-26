require 'swagger_helper'

shared_context 'with ArticleCategoriesController api v1' do
  include ApiHelper

  path '/article_categories' do
    get 'article categories' do
      tags 'Category'
      produces 'application/json'
      pagination_param
      let(:order_article) { create(:order, article_count: 1).order_articles.first }
      let(:stock_article) { create(:stock_article) }
      let(:stock_order_article) { create(:stock_order, article_ids: [stock_article.id]).order_articles.first }

      response '200', 'success' do
        schema type: :object, properties: {
          article_categories: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/ArticleCategory'
            }
          }
        }
        run_test!
      end

      it_handles_invalid_token
    end
  end

  path '/article_categories/{id}' do
    get 'find article category by id' do
      tags 'Category'
      produces 'application/json'
      id_url_param

      response '200', 'article category found' do
        schema type: :object, properties: {
          article_categories: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/ArticleCategory'
            }
          }
        }
        let(:id) { create(:article_category, name: 'dairy').id }
        run_test!
      end
      it_handles_invalid_token_with_id
      it_cannot_find_object
    end
  end
end
