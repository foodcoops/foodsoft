class OidcLoginController < ApplicationController
  skip_before_action :authenticate
  before_action :require_oidc_enabled

  # 1. Initiate OIDC Authorization Flow
  def initiate
    state = SecureRandom.hex(16)
    nonce = SecureRandom.hex(16)
    session[:oidc_state] = state
    session[:oidc_nonce] = nonce

    endpoints = oidc_endpoints
    query_params = {
      client_id: FoodsoftConfig[:oidc_client_id],
      response_type: 'code',
      scope: 'openid email profile',
      redirect_uri: oidc_callback_url,
      state: state,
      nonce: nonce
    }
    
    redirect_to "#{endpoints[:authorization_endpoint]}?#{query_params.to_query}", allow_other_host: true
  end

  # 2. Handle OIDC Callback Redirection
  def callback
    if params[:error].present?
      raise "OIDC Provider Error: #{params[:error_description] || params[:error]}"
    end

    # State Validation
    raise "State verification failed" if params[:state].blank? || params[:state] != session[:oidc_state]
    session[:oidc_state] = nil

    # Exchange Authorization Code for Access & ID Tokens
    endpoints = oidc_endpoints
    uri = URI(endpoints[:token_endpoint])
    response = Net::HTTP.post_form(uri, {
      grant_type: 'authorization_code',
      code: params[:code],
      redirect_uri: oidc_callback_url,
      client_id: FoodsoftConfig[:oidc_client_id],
      client_secret: FoodsoftConfig[:oidc_client_secret]
    })
    
    raise "Token exchange failed: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
    token_data = JSON.parse(response.body)
    
    # Fetch JWKS to cryptographically verify ID Token
    jwks_response = Net::HTTP.get(URI(endpoints[:jwks_uri]))
    jwks_keys = JSON.parse(jwks_response)

    # Decode and Verify ID Token Signature
    decoded_token = JWT.decode(
      token_data['id_token'],
      nil,
      true,
      {
        algorithms: ['RS256'],
        jwks: jwks_keys,
        aud: FoodsoftConfig[:oidc_client_id],
        verify_aud: true,
        iss: FoodsoftConfig[:oidc_issuer],
        verify_iss: true
      }
    )
    payload = decoded_token.first
    
    # Nonce Validation
    raise "Nonce verification failed" if payload['nonce'] != session[:oidc_nonce]
    session[:oidc_nonce] = nil

    # Find or provision user
    user = find_or_create_user(payload)
    
    # Synchronize OIDC group memberships
    sync_user_groups(user, payload)

    # Establish User Session
    user.update_attribute(:last_login, Time.now)
    login_and_redirect_to_return_to user, notice: I18n.t('sessions.logged_in')
  rescue StandardError => e
    Rails.logger.error "OIDC Authentication Failed: #{e.message}\n#{e.backtrace.join("\n")}"
    redirect_to login_url, alert: "SSO Authentication Failed: #{e.message}"
  end

  private

  def require_oidc_enabled
    raise "OIDC authentication is not enabled" unless FoodsoftConfig[:oidc_enabled]
  end

  # Resolve endpoints via OIDC discovery document or fallback parameters
  def oidc_endpoints
    issuer = FoodsoftConfig[:oidc_issuer]
    if issuer.present? && (FoodsoftConfig[:oidc_authorization_endpoint].blank? || FoodsoftConfig[:oidc_token_endpoint].blank? || FoodsoftConfig[:oidc_jwks_uri].blank?)
      discovery_uri = URI("#{issuer.chomp('/')}/.well-known/openid-configuration")
      discovery_response = Net::HTTP.get(discovery_uri)
      raise "Failed to fetch OIDC discovery document" unless discovery_response.is_a?(String)
      discovery_data = JSON.parse(discovery_response)
      {
        authorization_endpoint: discovery_data['authorization_endpoint'],
        token_endpoint: discovery_data['token_endpoint'],
        jwks_uri: discovery_data['jwks_uri']
      }
    else
      {
        authorization_endpoint: FoodsoftConfig[:oidc_authorization_endpoint],
        token_endpoint: FoodsoftConfig[:oidc_token_endpoint],
        jwks_uri: FoodsoftConfig[:oidc_jwks_uri]
      }
    end
  end

  # Find user by email or auto-create a new profile if permitted
  def find_or_create_user(payload)
    email = payload['email']
    raise "OIDC token payload is missing 'email' claim" if email.blank?

    user = User.undeleted.find_by('lower(email) = ?', email.downcase)
    return user if user

    raise "No Foodsoft account matches email #{email}" unless FoodsoftConfig[:oidc_auto_create_user]

    # Generate a unique username from claims or email prefix
    username = payload['preferred_username'] || payload['nickname'] || email.split('@').first
    if User.where('lower(nick) = ?', username.downcase).exists?
      username = "#{username}_#{SecureRandom.hex(3)}"
    end

    User.create! do |u|
      u.email = email
      u.nick = username
      u.first_name = payload['given_name'] || payload['name'] || "SSO User"
      u.last_name = payload['family_name'] || ""
      u.password = SecureRandom.hex(16) # Set a random password within standard validation constraints (5-50 chars)
    end
  end

  # Sync user groups
  def sync_user_groups(user, payload)
    groups_claim = FoodsoftConfig[:oidc_groups_claim] || 'groups'
    oidc_group_names = Array(payload[groups_claim]).map(&:to_s).map(&:strip).reject(&:blank?)

    target_groups = []

    if oidc_group_names.present?
      oidc_group_names.each do |group_name|
        group = Group.undeleted.find_by('lower(name) = ?', group_name.downcase)
        
        if group.nil? && FoodsoftConfig[:oidc_auto_create_ordergroup]
          group = Ordergroup.create!(name: group_name)
        end

        target_groups << group if group.present?
      end
    end

    # Fallback to default group if no OIDC group is matched or assigned
    if target_groups.blank? && FoodsoftConfig[:oidc_default_ordergroup].present?
      fallback_identifier = FoodsoftConfig[:oidc_default_ordergroup]
      fallback_group = if fallback_identifier.to_s =~ /\A\d+\z/
                         Group.undeleted.find_by(id: fallback_identifier.to_i)
                       else
                         Group.undeleted.find_by('lower(name) = ?', fallback_identifier.to_s.downcase)
                       end
      target_groups << fallback_group if fallback_group.present?
    end

    # Associate user with the matched/created groups
    target_groups.each do |group|
      Membership.find_or_create_by!(user: user, group: group)
    end

    # Strictly sync user's groups if configured
    if FoodsoftConfig[:oidc_sync_groups_strictly]
      user.memberships.each do |membership|
        unless target_groups.include?(membership.group)
          # Preserve admin role groups from automatic pruning
          membership.destroy! unless membership.group.role_admin?
        end
      end
    end
  end
end
