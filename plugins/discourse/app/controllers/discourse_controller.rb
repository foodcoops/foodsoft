class DiscourseController < ApplicationController

  before_filter -> { require_plugin_enabled FoodsoftDiscourse }
  skip_before_filter :authenticate

  def initiate
    discourse_url = FoodsoftConfig[:discourse_url]

    nonce = SecureRandom.hex()
    return_sso_url = url_for(action: :callback, only_path: false)
    payload = "nonce=#{nonce}&return_sso_url=#{return_sso_url}"
    base64_payload = Base64.encode64 payload
    sso = URI.escape base64_payload
    sig = get_hmac_hex_string base64_payload

    session[:discourse_sso_nonce] = nonce
    redirect_to "#{discourse_url}/session/sso_provider?sso=#{sso}&sig=#{sig}"
  end

  def callback
    raise I18n.t('discourse.callback.invalid_signature') if get_hmac_hex_string(params[:sso]) != params[:sig]

    info = Rack::Utils.parse_query(Base64.decode64(params[:sso]))
    info.symbolize_keys!

    raise I18n.t('discourse.callback.invalid_nonce') if info[:nonce] != session[:discourse_sso_nonce]
    session[:discourse_sso_nonce] = nil

    id = info[:external_id].to_i
    user = User.find_or_initialize_by(id: id) do |user|
      user.id = id
      user.password = SecureRandom.random_bytes(25)
    end
    user.nick = info[:username]
    user.email = info[:email]
    user.first_name = info[:name]
    user.last_name = ''
    user.last_login = Time.now
    user.save!

    login_and_redirect_to_return_to user, :notice => I18n.t('discourse.callback.logged_in')
  rescue => error
    redirect_to login_url, :alert => error.to_s
  end

  private

  def get_hmac_hex_string payload
    discourse_sso_secret = FoodsoftConfig[:discourse_sso_secret]
    OpenSSL::HMAC.hexdigest 'sha256', discourse_sso_secret, payload
  end
end
