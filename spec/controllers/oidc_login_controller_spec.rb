# frozen_string_literal: true

require 'spec_helper'

describe OidcLoginController do
  let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:jwk) { JWT::JWK.new(rsa_key) }
  let(:jwk_hash) { jwk.export.merge('kid' => 'test-kid') }
  let(:jwks) { { 'keys' => [jwk_hash] } }

  let(:issuer) { 'https://keycloak.example.com' }
  let(:client_id) { 'foodsoft-client' }
  let(:client_secret) { 'secret' }

  let(:token_payload) do
    {
      'iss' => issuer,
      'aud' => client_id,
      'sub' => '12345',
      'email' => 'sso@example.com',
      'preferred_username' => 'ssouser',
      'given_name' => 'SSO',
      'family_name' => 'User',
      'nonce' => 'test-nonce',
      'exp' => Time.now.to_i + 3600,
      'groups' => ['Ordergroup-Apples']
    }
  end

  let(:id_token) do
    JWT.encode(token_payload, rsa_key, 'RS256', { 'kid' => 'test-kid' })
  end

  before do
    allow(FoodsoftConfig).to receive(:[]).and_call_original
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_enabled).and_return(true)
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_client_id).and_return(client_id)
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_client_secret).and_return(client_secret)
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_issuer).and_return(issuer)
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_authorization_endpoint).and_return("#{issuer}/auth")
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_token_endpoint).and_return("#{issuer}/token")
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_jwks_uri).and_return("#{issuer}/certs")
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_button_label).and_return("SSO Login")
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_auto_create_user).and_return(true)
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_groups_claim).and_return('groups')
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_auto_create_ordergroup).and_return(true)
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_default_ordergroup).and_return(nil)
    allow(FoodsoftConfig).to receive(:[]).with(:oidc_sync_groups_strictly).and_return(false)
  end

  describe 'GET initiate' do
    it 'redirects to OIDC provider and sets state/nonce in session' do
      get_with_defaults :initiate
      expect(response).to have_http_status(:redirect)
      expect(response.location).to start_with("#{issuer}/auth")
      expect(session[:oidc_state]).not_to be_nil
      expect(session[:oidc_nonce]).not_to be_nil
    end
  end

  describe 'GET callback' do
    let(:state) { 'test-state' }
    let(:nonce) { 'test-nonce' }

    before do
      session[:oidc_state] = state
      session[:oidc_nonce] = nonce

      # Mock Token Exchange Response
      token_response = double('response', body: { id_token: id_token }.to_json)
      allow(token_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      allow(Net::HTTP).to receive(:post_form).and_return(token_response)

      # Mock JWKS Endpoint Response
      allow(Net::HTTP).to receive(:get).with(URI("#{issuer}/certs")).and_return(jwks.to_json)
    end

    it 'authenticates and creates new user and group' do
      expect {
        get_with_defaults :callback, params: { code: 'auth-code', state: state }
      }.to change(User, :count).by(1).and change(Ordergroup, :count).by(1)

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).not_to be_nil

      created_user = User.last
      expect(created_user.email).to eq('sso@example.com')
      expect(created_user.nick).to eq('ssouser')

      created_group = Ordergroup.last
      expect(created_group.name).to eq('Ordergroup-Apples')
      expect(created_user.groups).to include(created_group)
    end

    it 'logs in an existing user' do
      existing_user = create(:user, email: 'sso@example.com')

      expect {
        get_with_defaults :callback, params: { code: 'auth-code', state: state }
      }.not_to change(User, :count)

      expect(response).to redirect_to(root_path)
      expect(session[:user_id]).to eq(existing_user.id)
    end

    it 'fails when state is invalid' do
      get_with_defaults :callback, params: { code: 'auth-code', state: 'wrong-state' }
      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to match(/SSO Authentication Failed/)
    end
  end
end
