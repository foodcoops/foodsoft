# frozen_string_literal: true

require 'spec_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      components: {
        schemas: {
          Error: {
            type: :object,
            properties: {
              error: {
                type: :string,
                description: 'error code'
              },
              error_description: {
                type: :string,
                description: 'human-readable error message (localized)'
              }
            }
          },
          Error401: {
            type: :object,
            properties: {
              error: {
                type: :string,
                description: '<tt>unauthorized</tt>'
              },
              error_description: {
                '$ref': '#/components/schemas/Error/properties/error_description'
              }
            }
          },
          Error403: {
            type: :object,
            properties: {
              error: {
                type: :string,
                description: '<tt>forbidden</tt> or <tt>invalid_scope</tt>'
              },
              error_description: {
                '$ref': '#/components/schemas/Error/properties/error_description'
              }
            }
          },
          Error404: {
            type: :object,
            properties: {
              error: {
                type: :string,
                description: '<tt>not_found</tt>'
              },
              error_description: {
                '$ref': '#/components/schemas/Error/properties/error_description'
              }
            }
          },
          Error422: {
            type: :object,
            properties: {
              error: {
                type: :string,
                description: 'unprocessable entity'
              },
              error_description: {
                '$ref': '#/components/schemas/Error/properties/error_description'
              }
            }
          }
        },
        securitySchemes: {
          oauth2: {
            type: :oauth2,
            flows: {
              implicit: {
                authorizationUrl: 'http://localhost:3000/f/oauth/authorize',
                scopes: {
                  'config:user': 'reading Foodsoft configuration for regular users',
                  'config:read': 'reading Foodsoft configuration values',
                  'config:write': 'reading and updating Foodsoft configuration values',
                  'finance:user': 'accessing your own financial transactions',
                  'finance:read': 'reading all financial transactions',
                  'finance:write': 'reading and creating financial transactions',
                  'user:read': 'reading your own user profile',
                  'user:write': 'reading and updating your own user profile',
                  offline_access: 'retain access after user has logged out'
                }
              }
            }
          }
        }
      },
      servers: [
        {
          url: 'http://{defaultHost}/f/api/v1',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ],
      security: [
        oauth2: [
          'user:read'
        ]
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
