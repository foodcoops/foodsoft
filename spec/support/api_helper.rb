module ApiHelper
  extend ActiveSupport::Concern

  included do
    let(:user) { create(:user) }
    let(:api_scopes) { [] } # empty scopes for stricter testing (in reality this would be default_scopes)
    let(:api_access_token) { create(:oauth2_access_token, resource_owner_id: user.id, scopes: api_scopes&.join(' ')).token }
    let(:Authorization) { "Bearer #{api_access_token}" }

    # TODO: not needed anymore?
    def self.it_handles_invalid_token()
      context 'with invalid access token' do
        let(:Authorization) { 'abc' }

        response 401, 'not logged-in' do
          run_test!
        end
      end
    end

    def self.it_handles_invalid_scope()
      context 'with invalid scope' do
        let(:api_scopes) { ['none'] }

        response 403, 'missing scope' do
          run_test!
        end
      end
    end

    def self.it_handles_invalid_token_and_scope(*args)
      it_handles_invalid_token(*args)
      it_handles_invalid_scope(*args)
    end
  end

  # Add authentication to parameters for {Swagger::RspecHelpers#validate}
  # @param params [Hash] Query parameters
  # @return Query parameters with authentication header
  # @see Swagger::RspecHelpers#validate
  # def api_auth(params = {})
  #   { '_headers' => { 'Authorization' => api_authorization } }.deep_merge(params)
  # end
  # TODO: not needed anymore
end
