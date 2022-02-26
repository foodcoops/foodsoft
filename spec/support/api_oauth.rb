# Dummy OAuth implementation with +current_user+ and scopes
module ApiOAuth
  extend ActiveSupport::Concern

  included do
    let(:user) { build(:user) }
    let(:api_scopes) { [] } # empty scopes for stricter testing (in reality this would be default_scopes)
    let(:api_access_token) { double(:acceptable? => true, :accessible? => true, scopes: api_scopes) }
    before { allow(controller).to receive(:doorkeeper_token) { api_access_token } }

    before { allow(controller).to receive(:current_user) { user } }

    let(:json_response) { JSON.parse(response.body) }
  end
end
