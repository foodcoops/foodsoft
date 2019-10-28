class DiscourseSsoController < DiscourseController

  before_action -> { require_config_enabled :discourse_sso }

  def sso
    raise I18n.t('discourse.sso.invalid_signature') unless valid_signature?

    payload = parse_payload
    nonce = payload[:nonce]
    return_sso_url = payload[:return_sso_url] || "#{discourse_url}/session/sso_login"

    raise I18n.t('discourse.sso.nonce_missing') if nonce.blank?

    redirect_to_with_payload return_sso_url,
      nonce: nonce,
      email: current_user.email,
      require_activation: true,
      external_id: "#{FoodsoftConfig.scope}/#{current_user.id}",
      username: current_user.nick,
      name: current_user.name
  rescue => error
    redirect_to root_url, alert: error.to_s
  end

end
