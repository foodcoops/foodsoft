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
      openapi: '3.0.3',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      components: {
        schemas: {
          pagination: {
            type: :object,
            properties: {
              recordCount: { type: :integer },
              pageCount: { type: :integer },
              currentPage: { type: :integer },
              pageSize: { type: :integer }
            },
            required: %w[recordCount pageCount currentPage pageSize]
          },
          Order: {
            type: :object,
            properties: {
              id: {
                type: :integer
              },
              name: {
                type: :string,
                description: "name of the order's supplier (or stock)"
              },
              starts: {
                type: :string,
                format: 'date-time',
                description: 'when the order was opened'
              },
              ends: {
                type: :string,
                nullable: true,
                format: 'date-time',
                description: 'when the order will close or was closed'
              },
              boxfill: {
                type: :string,
                nullable: true,
                format: 'date-time',
                description: 'when the order will enter or entered the boxfill phase'
              },
              pickup: {
                type: :string,
                nullable: true,
                format: :date,
                description: 'pickup date'
              },
              is_open: {
                type: :boolean,
                description: 'if the order is currently open or not'
              },
              is_boxfill: {
                type: :boolean,
                description: 'if the order is currently in the boxfill phase or not'
              }
            }
          },
          ExternalArticle: {
            description: 'article for external client with the data of its latest version',
            type: :object,
            properties: {
              price: { type: :float },
              tax: { type: :float },
              deposit: { type: :float },
              created_at: {
                type: :string,
                format: 'date-time'
              },
              name: { type: :string },
              unit: {
                type: :string,
                deprecated: true,
                nullable: true,
                description: 'old style plain text amount of each unit, e.g. "100 g" or "kg"'
              },
              note: {
                type: :string,
                nullable: true,
                description: 'generic note'
              },
              availability: {
                type: :boolean,
                description: 'whether the article can be used in active orders'
              },
              manufacturer: {
                type: :string,
                nullable: true,
                description: 'manufacturer'
              },
              origin: {
                type: :string,
                nullable: true,
                description: 'origin, preferably (starting with a) 2-letter ISO country code'
              },
              order_number: {
                type: :string,
                nullable: true,
                description: 'number uniquely identifying the article amongst other articles of this supplier'
              },
              updated_at: {
                type: :string,
                format: 'date-time'
              },
              supplier_order_unit: {
                type: :string,
                nullable: true,
                description: 'the UN/ECE unit the article is delivered in (if null, the deprecated plain text `unit` is used instead)'
              },
              price_unit: {
                type: :string,
                nullable: true,
                description: 'the UN/ECE unit the article\'s price is displayed in (if null, the deprecated plain text `unit` is used instead)'
              },
              billing_unit: {
                type: :string,
                nullable: true,
                description: 'the UN/ECE unit the article\'s price is billed in (if null, the deprecated plain text `unit` is used instead)'
              },
              group_order_unit: {
                type: :string,
                nullable: true,
                description: 'the UN/ECE unit the article can be ordered in by distinct order groups (if null, the deprecated plain text `unit` is used instead)'
              },
              group_order_granularity: {
                type: :float,
                description: 'the granularity in which order groups may order this article (measured in `group_order_unit`)'
              },
              minimum_order_quantity: {
                type: :float,
                description: 'minimum quantity that needs to be achieved for the article to be ordered at all (measured in `group_order_unit`)'
              },
              article_unit_ratios: {
                type: :array,
                items: {
                  '$ref': '#/components/schemas/ExternalArticleUnitRatio'
                }
              }
            }
          },
          ExternalArticleUnitRatio: {
            type: :object,
            properties: {
              unit: {
                type: :string,
                description: 'the UN/ECE unit of this ratio'
              },
              quantity: {
                type: :float,
                description: 'the quantity of this ratio relative to `supplier_order_unit` (or `unit` if `supplier_order_unit` is null)'
              },
              sort: {
                type: :integer,
                description: 'sort index'
              }
            }
          },
          Article: {
            type: :object,
            properties: {
              id: {
                type: :integer
              },
              name: {
                type: :string
              },
              supplier_id: {
                type: :integer,
                description: 'id of supplier, or 0 for stock articles'
              },
              supplier_name: {
                type: :string,
                nullable: true,
                description: 'name of the supplier, or null for stock articles'
              },
              unit: {
                type: :string,
                description: 'amount of each unit, e.g. "100 g" or "kg"'
              },
              unit_quantity: {
                type: :integer,
                description: 'units can only be ordered from the supplier in multiples of unit_quantity'
              },
              note: {
                type: :string,
                nullable: true,
                description: 'generic note'
              },
              manufacturer: {
                type: :string,
                nullable: true,
                description: 'manufacturer'
              },
              origin: {
                type: :string,
                nullable: true,
                description: 'origin, preferably (starting with a) 2-letter ISO country code'
              },
              article_category_id: {
                type: :integer,
                description: 'id of article category'
              },
              quantity_available: {
                type: :integer,
                description: 'number of units available (only present on stock articles)'
              }
            },
            required: %w[id name supplier_id supplier_name unit unit_quantity note manufacturer origin
                         article_category_id]
          },
          OrderArticle: {
            type: :object,
            properties: {
              id: {
                type: :integer
              },
              order_id: {
                type: :integer,
                description: 'id of order this order article belongs to'
              },
              price: {
                type: :number,
                format: :float,
                description: 'foodcoop price'
              },
              quantity: {
                type: :float,
                description: 'number of units ordered by members'
              },
              tolerance: {
                type: :float,
                description: 'number of extra units that members are willing to buy to fill a box'
              },
              units_to_order: {
                type: :float,
                description: 'number of units to order from the supplier'
              },
              article: {
                '$ref': '#/components/schemas/Article'
              }
            }
          },
          ArticleCategory: {
            type: :object,
            properties: {
              id: {
                type: :integer
              },
              name: {
                type: :string
              }
            },
            required: %w[id name]
          },
          FinancialTransaction: {
            allOf: [
              { '$ref': '#/components/schemas/FinancialTransactionForCreate' },
              {
                type: :object,
                properties: {
                  id: {
                    type: :integer
                  },
                  amount: {
                    type: :number,
                    format: :float,
                    nullable: true,
                    description: 'amount credited. Negative for a debit transaction, null for an incomplete transaction.'
                  },
                  financial_transaction_type_id: {
                    type: :integer,
                    description: 'id of the type of the transaction'
                  },
                  note: {
                    type: :string,
                    description: 'note entered with the transaction'
                  },
                  user_id: {
                    type: :integer,
                    nullable: true,
                    description: 'id of user who entered the transaction (may be <tt>null</tt> for deleted users or 0 for a system user)'
                  },
                  user_name: {
                    type: :string,
                    nullable: true,
                    description: 'name of user who entered the transaction (may be <tt>null</tt> or empty string for deleted users or system users)'
                  },
                  financial_transaction_type_name: {
                    type: :string,
                    description: 'name of the type of the transaction'
                  },
                  created_at: {
                    type: :string,
                    format: 'date-time',
                    description: 'when the transaction was entered'
                  }
                },
                required: %w[id user_id user_name financial_transaction_type_name created_at]
              }
            ]
          },
          FinancialTransactionForCreate: {
            type: :object,
            properties: {
              amount: {
                type: :number,
                format: :float,
                description: 'amount credited (negative for a debit transaction)'
              },
              financial_transaction_type_id:
              {
                type: :integer,
                description: 'id of the type of the transaction'
              },
              note: {
                type: :string,
                description: 'note entered with the transaction'
              }
            },
            required: %w[amount note user_id]
          },
          FinancialTransactionClass: {
            type: :object,
            properties: {
              id: {
                type: :integer
              },
              name: {
                type: :string
              }
            },
            required: %w[id name]
          },
          FinancialTransactionType: {
            type: :object,
            properties: {
              id: {
                type: :integer
              },
              name: {
                type: :string
              },
              name_short: {
                type: :string,
                nullable: true,
                description: 'short name (used for bank transfers)'
              },
              bank_account_id: {
                type: :integer,
                nullable: true,
                description: 'id of the bank account used for this transaction type'
              },
              bank_account_name: {
                type: :string,
                nullable: true,
                description: 'name of the bank account used for this transaction type'
              },
              bank_account_iban: {
                type: :string,
                nullable: true,
                description: 'IBAN of the bank account used for this transaction type'
              },
              financial_transaction_class_id: {
                type: :integer,
                description: 'id of the class of the transaction'
              },
              financial_transaction_class_name: {
                type: :string,
                description: 'name of the class of the transaction'
              }
            },
            required: %w[id name financial_transaction_class_id financial_transaction_class_name]
          },
          GroupOrderArticleForUpdate: {
            type: :object,
            properties: {
              quantity:
              {
                type: :float,
                description: 'number of units ordered by the users ordergroup'
              },
              tolerance:
              {
                type: :float,
                description: 'number of extra units the users ordergroup is willing to buy for filling a box'
              }
            }
          },
          GroupOrderArticleForCreate: {
            allOf: [
              { '$ref': '#/components/schemas/GroupOrderArticleForUpdate' },
              {
                type: :object,
                properties: {
                  order_article_id:
                  {
                    type: :integer,
                    description: 'id of order article'
                  }
                }
              }
            ]
          },
          GroupOrderArticle: {
            allOf: [
              { '$ref': '#/components/schemas/GroupOrderArticleForCreate' },
              {
                type: :object,
                properties: {
                  id: {
                    type: :integer
                  },
                  result: {
                    type: :float,
                    description: 'number of units the users ordergroup will receive or has received'
                  },
                  total_price:
                  {
                    type: :number,
                    format: :float,
                    description: 'total price of this group order article'
                  },
                  order_article_id:
                  {
                    type: :integer,
                    description: 'id of order article'
                  }
                },
                required: %w[order_article_id]
              }
            ]
          },
          q_ordered: {
            type: :object,
            properties: {
              ordered: {
                type: :string,
                enum: %w[member all supplier]
              }
            }
          },
          Meta: {
            type: :object,
            properties: {
              page: {
                type: :integer,
                description: 'page number of the returned collection'
              },
              per_page: {
                type: :integer,
                description: 'number of items per page'
              },
              total_pages: {
                type: :integer,
                description: 'total number of pages'
              },
              total_count: {
                type: :integer,
                description: 'total number of items in the collection'
              }
            },
            required: %w[page per_page total_pages total_count]
          },
          Navigation: {
            type: :array,
            items: {
              type: :object,
              properties: {
                name: {
                  type: :string,
                  description: 'title'
                },
                url: {
                  type: :string,
                  description: 'link'
                },
                items: {
                  '$ref': '#/components/schemas/Navigation'
                }
              },
              required: ['name'],
              minProperties: 2 # name+url or name+items
            }
          },
          Pagination: {
            type: :object,
            nullable: true,
            properties: {
              current_page: {
                type: :integer,
                description: 'page number of the returned collection'
              },
              previous_page: {
                type: :integer,
                nullable: true,
                description: 'previous page'
              },
              next_page: {
                type: :integer,
                nullable: true,
                description: 'next page'
              },
              per_page: {
                type: :integer,
                description: 'number of items per page'
              },
              total_pages: {
                type: :integer,
                description: 'total number of pages'
              },
              number: {
                type: :integer,
                description: 'total number of items in the collection'
              }
            }
          },
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
                description: '<tt>unprocessable entity</tt>'
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
