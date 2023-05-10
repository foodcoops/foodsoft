require 'swagger_helper'

describe 'Admin', type: :request do
  include ApiHelper

  let(:api_scopes) { ['user:write'] }
  let(:user) { create :user }
  let(:other_user1) { create :user, groups: [create(:ordergroup)] }
  let(:other_user2) { create :user }
  let(:other_user3) { create :user, deleted_at: DateTime.now }

  before do
    user
  end

  path '/admin/users' do
    context 'group tests that require several users to save some execution time' do
      before do
        other_user1
        other_user2
        other_user3
      end

      get('users') do
        tags 'Admin', 'User'
        produces 'application/json'
        pagination_param
        parameter name: :show_deleted, in: :query, type: :boolean, required: false
        let(:per_page) { 2 }

        response '200', 'success' do
          schema type: :object, properties: {
            meta: { '$ref': '#/components/schemas/Meta' },
            users: {
              type: :array,
              items: {
                '$ref': '#/components/schemas/User'
              }
            }
          }, additionalProperties: false
          run_test! do |response|
            data = JSON.parse(response.body)
            Rails.logger.debug "RESPONSE"
            Rails.logger.debug JSON.parse(response.body)
            expect(data['users'].first['id']).to eq(user.id)
            expect(data['users'].second['ordergroupid']).to be_a(Integer)
            expect(data['meta']['page']).to eq(1)
            expect(data['meta']['per_page']).to eq(2)
            expect(data['meta']['total_pages']).to eq(2)
            expect(data['meta']['total_count']).to eq(3)
          end
        end

        response '200', 'success' do
          schema type: :object, properties: {
            meta: { '$ref': '#/components/schemas/Meta' },
            users: {
              type: :array,
              items: {
                '$ref': '#/components/schemas/UserDeleted'
              }
            }
          }, additionalProperties: false
          let(:show_deleted) { 1 }
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['users'].first['id']).to eq(other_user3.id)
            expect(data['meta']['total_pages']).to eq(1)
            expect(data['meta']['total_count']).to eq(1)
          end
        end
      end
    end

    post('create user') do
      tags 'Admin', 'User'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user1, in: :body,
                description: 'user to create',
                required: true,
                schema: { '$ref': '#/components/schemas/UserForCreate' }

      response '200', 'success' do
        let(:user1) {{
          first_name: Faker::Name.first_name,
          email: Faker::Internet.email,
          password: Faker::Internet.password,
          create_ordergroup: true
        }}
        schema(
          type: :object,
          properties: { user: { allOf: [{ '$ref': '#/components/schemas/User' }]}},
          additionalProperties: false
        )
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user']['ordergroupid']).to be_a(Integer)
        end
      end

      response '422', 'invalid or missing parameters' do
        let(:user1) {{
          first_name: Faker::Name.first_name
        }}
        schema '$ref' => '#/components/schemas/Error404'
        run_test!
      end
    end
  end

  path '/admin/users/{id}' do
    get 'show user' do
      tags 'Admin', 'User'
      produces 'application/json'
      id_url_param

      response '200', 'success' do
        schema(
          type: :object,
          properties: { user: { allOf: [{ '$ref': '#/components/schemas/User' }]}},
          additionalProperties: false
        )
        let(:id) { other_user1.id }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user']['id']).to eq(other_user1.id)
          expect(data['user']['ordergroupid']).to be_a(Integer)
        end
      end

      it_handles_invalid_scope_with_id
      it_handles_invalid_token_with_id
      it_cannot_find_object 'user not found'
    end

    patch 'update user' do
      tags 'Admin', 'User'
      consumes 'application/json'
      produces 'application/json'
      id_url_param
      parameter name: :usertoupdate, in: :body,
                description: 'user to create',
                required: true,
                schema: { '$ref': '#/components/schemas/UserForUpdate' }
      let(:usertoupdate) {
        {
          first_name: Faker::Name.first_name,
          email: Faker::Internet.email,
          password: Faker::Internet.password
        }
      }

      response '200', 'success' do
        let(:id) { user.id }
        schema(
          type: :object,
          properties: { user: { allOf: [{ '$ref': '#/components/schemas/User' }] } },
          additionalProperties: false
        )
        run_test!
      end

      response '422', 'invalid or missing parameters' do
        let(:id) { user.id }
        let(:usertoupdate) { { settings_attributes: { notify: { order_finished: 'invalid' } } } }
        schema '$ref' => '#/components/schemas/Error422'
        run_test!
      end

      it_handles_invalid_scope_with_id
      it_handles_invalid_token_with_id
      it_cannot_find_object 'user not found'
    end

    delete 'delete user' do
      tags 'Admin', 'User'
      produces 'application/json'
      id_url_param

      response '200', 'success' do
        let(:id) { user.id }
        schema(
          type: :object,
          properties: { user: { allOf: [{ '$ref': '#/components/schemas/UserDeleted' }] } },
          additionalProperties: false
        )
        run_test! do
          user.restore
        end
      end

      it_handles_invalid_scope_with_id
      it_handles_invalid_token_with_id
      it_cannot_find_object 'user not found'
    end
  end

  path '/admin/users/{id}/restore' do
    post 'restore user' do
      tags 'Admin', 'User'
      produces 'application/json'
      id_url_param

      response '200', 'success' do
        let(:id) { other_user3.id }
        schema(
          type: :object,
          properties: { user: { allOf: [{ '$ref': '#/components/schemas/User' }] } },
          additionalProperties: false
        )
        run_test! do
          other_user3.delete
        end
      end

      it_handles_invalid_scope_with_id
      it_handles_invalid_token_with_id
      it_cannot_find_object 'user not found'
    end
  end
end
