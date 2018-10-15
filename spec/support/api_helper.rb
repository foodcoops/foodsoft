module ApiHelper
  extend ActiveSupport::Concern

  included do
    let(:user) { create :user }
    let(:access_token) { create(:oauth2_access_token, resource_owner_id: user.id).token }
    let(:authorization) { "Bearer #{token}" }
  end

  # Add authentication to parameters for {Swagger::RspecHelpers#validate}
  # @param params [Hash] Query parameters
  # @return Query parameters with authentication header
  # @see Swagger::RspecHelpers#validate
  def auth(params = {})
    {'_headers' => {'Authorization' => "Bearer #{access_token}" }}.deep_merge(params)
  end

end
