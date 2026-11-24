class DiscourseSsoController < DiscourseController
  before_action -> { require_config_enabled :discourse_sso }

  def sso
    raise I18n.t('discourse.sso.invalid_signature') unless valid_signature?

    payload = parse_payload
    nonce = payload[:nonce]
    # Default to the configured Discourse instance when the peer doesn't say where to
    # return. A return_sso_url from the payload is only followed when it points to an
    # allowed host (see DiscourseController#allowed_sso_url), so a signed payload
    # cannot leak user data to an arbitrary host.
    return_sso_url = payload[:return_sso_url].presence || "#{discourse_url}/session/sso_login"

    raise I18n.t('discourse.sso.nonce_missing') if nonce.blank?

    redirect_to_with_payload return_sso_url,
                             nonce: nonce,
                             email: current_user.email,
                             require_activation: true,
                             external_id: "#{FoodsoftConfig.scope}/#{current_user.id}",
                             username: current_user.nick,
                             name: current_user.name
  rescue StandardError => e
    redirect_to root_url, alert: e.to_s
  end
end
