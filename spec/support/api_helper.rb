module ApiHelper
  extend ActiveSupport::Concern

  included do
    let(:user) { create(:user) }
    let(:api_scopes) { [] } # empty scopes for stricter testing (in reality this would be default_scopes)
    let(:api_access_token) { create(:oauth2_access_token, resource_owner_id: user.id, scopes: api_scopes&.join(' ')).token }
    let(:api_authorization) { "Bearer #{api_access_token}" }

    def self.it_handles_invalid_token(method, path, params_block = -> { api_auth })
      context 'with invalid access token' do
        let(:api_access_token) { 'abc' }

        it { is_expected.to validate(method, path, 401, instance_exec(&params_block)) }
      end
    end

    def self.it_handles_invalid_scope(method, path, params_block = -> { api_auth })
      context 'with invalid scope' do
        let(:api_scopes) { ['none'] }

        it { is_expected.to validate(method, path, 403, instance_exec(&params_block)) }
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
  def api_auth(params = {})
    { '_headers' => { 'Authorization' => api_authorization } }.deep_merge(params)
  end
end
