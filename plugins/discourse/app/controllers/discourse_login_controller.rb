class DiscourseLoginController < DiscourseController
  before_action -> { require_config_disabled :discourse_sso }
  skip_before_action :authenticate

  def initiate
    discourse_url = FoodsoftConfig[:discourse_url]

    nonce = SecureRandom.hex()
    return_sso_url = url_for(action: :callback, only_path: false)

    session[:discourse_sso_nonce] = nonce
    redirect_to_with_payload "#{discourse_url}/session/sso_provider",
                             nonce: nonce,
                             return_sso_url: return_sso_url
  end

  def callback
    raise I18n.t('discourse.callback.invalid_signature') unless valid_signature?

    payload = parse_payload

    raise I18n.t('discourse.callback.invalid_nonce') if payload[:nonce] != session[:discourse_sso_nonce]

    session[:discourse_sso_nonce] = nil

    id = payload[:external_id].to_i
    user = User.find_or_initialize_by(id: id) do |user|
      user.id = id
      user.password = SecureRandom.random_bytes(25)
    end
    user.nick = payload[:username]
    user.email = payload[:email]
    user.first_name = payload[:name]
    user.last_name = ''
    user.last_login = Time.now
    user.save!

    login_and_redirect_to_return_to user, notice: I18n.t('discourse.callback.logged_in')
  rescue => error
    redirect_to login_url, alert: error.to_s
  end
end
