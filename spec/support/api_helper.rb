module ApiHelper
  extend ActiveSupport::Concern

  included do
    let(:user) { create(:user) }
    let(:api_access_token) { create(:oauth2_access_token, resource_owner_id: user.id).token }
    let(:api_authorization) { "Bearer #{api_access_token}" }
  end

  # Add authentication to parameters for {Swagger::RspecHelpers#validate}
  # @param params [Hash] Query parameters
  # @return Query parameters with authentication header
  # @see Swagger::RspecHelpers#validate
  def api_auth(params = {})
    {'_headers' => {'Authorization' => api_authorization }}.deep_merge(params)
  end

end
