require 'swagger_helper'

def success_schema
  {
    type: :object,
    properties: {
      articles: {
        type: :array,
        items: {
          '$ref': '#/components/schemas/ExternalArticle'
        }
      },
      latest_update: {
        type: :string,
        nullable: true,
        format: 'date-time',
        description: 'latest update to any of the supplier\'s articles'
      },
      pagination: {
        '$ref': '#/components/schemas/Pagination'
      }
    }
  }
end

describe 'shared supplier articles' do
  include ApiHelper
  let(:api_scopes) { ['shared_suppliers:articles'] }

  path '/shared_suppliers/{uuid}/articles' do
    get 'retrieve articles' do
      tags 'Supplier'
      produces 'application/json'
      parameter name: :uuid, in: :path, type: :string, required: true, description: 'the external UUID of the supplier'
      parameter name: :updated_after, in: :query, type: :string, format: 'date-time', required: false, description: 'only retrieve articles after this date time'
      parameter name: :origin, in: :query, type: :string, required: false, description: 'filter by article origin'
      parameter name: :name, in: :query, type: :string, required: false, description: 'filter by article name fragment'
      parameter name: :page, in: :query, type: :number, required: false, description: 'pagination: number of the page to retrieve'
      parameter name: :per_page, in: :query, type: :number, required: false, description: 'pagination: items per page'
      let(:supplier) { create(:supplier, article_count: 10, external_uuid: 'test') }
      let(:uuid) { supplier.external_uuid }

      response '200', 'success' do
        schema(success_schema)
        run_test! do |response|
          expect(JSON.parse(response.body)['articles'].length).to eq 10
        end
      end

      context 'when filtered by updated_after' do
        let(:supplier) { create(:supplier, article_count: 10, external_uuid: 'test') }
        let(:uuid) { supplier.external_uuid }
        let(:updated_after) { 1.day.ago }

        before do
          supplier.articles[0..4].each do |article|
            article.update_attribute(:updated_at, 10.days.ago)
          end
          supplier.articles[5..9].each do |article|
            article.update_attribute(:updated_at, Time.now)
          end
        end

        response '200', 'success' do
          schema(success_schema)
          run_test! do |response|
            expect(JSON.parse(response.body)['articles'].length).to eq 5
          end
        end
      end

      context 'when filtered by origin' do
        let(:supplier) { create(:supplier, article_count: 10, external_uuid: 'test') }
        let(:uuid) { supplier.external_uuid }
        let(:origin) { 'TestOrigin' }

        before do
          supplier.articles[0..4].each do |article|
            article.update_attribute(:origin, 'TestOrigin')
          end
        end

        response '200', 'success' do
          schema(success_schema)
          run_test! do |response|
            expect(JSON.parse(response.body)['articles'].length).to eq 5
          end
        end
      end

      context 'when filtered by name' do
        let(:supplier) { create(:supplier, article_count: 10, external_uuid: 'test') }
        let(:uuid) { supplier.external_uuid }
        let(:name) { 'TestName' }

        before do
          supplier.articles[0..4].each_with_index do |article, index|
            article.update_attribute(:name, "TestName#{index}")
          end
        end

        response '200', 'success' do
          schema(success_schema)
          run_test! do |response|
            expect(JSON.parse(response.body)['articles'].length).to eq 5
          end
        end
      end

      context 'when paginating' do
        let(:supplier) { create(:supplier, article_count: 10, external_uuid: 'test') }
        let(:uuid) { supplier.external_uuid }
        let(:page) { 2 }
        let(:per_page) { 5 }

        response '200', 'success' do
          schema(success_schema)
          run_test! do |response|
            parsed_response = JSON.parse(response.body)
            expect(parsed_response['articles']&.length).to eq 5
            pagination_response = parsed_response['pagination']
            expect(pagination_response&.dig('current_page')).to eq 2
            expect(pagination_response&.dig('total_pages')).to eq 2
            expect(pagination_response&.dig('previous_page')).to eq 1
            expect(pagination_response&.dig('next_page')).to be_nil
          end
        end
      end

      context 'with invalid supplier uuid' do
        let(:uuid) { 'invalid' }

        response '404', 'not found' do
          schema '$ref' => '#/components/schemas/Error404'

          run_test!
        end
      end
    end
  end
end
