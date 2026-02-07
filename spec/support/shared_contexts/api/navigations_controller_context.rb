require 'swagger_helper'

shared_context 'with NavigationsController api v1' do
  include ApiHelper

  path '/navigation' do
    get 'navigation' do
      tags 'General'
      produces 'application/json'

      response '200', 'success' do
        schema type: :object, properties: {
          navigation: {
            '$ref' => '#/components/schemas/Navigation'
          }
        }

        run_test!
      end

      it_handles_invalid_token
    end
  end
end
