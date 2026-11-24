require 'uri'

class DiscourseController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftDiscourse }

  protected

  def valid_signature?
    return false if params[:sso].blank? || params[:sig].blank?

    get_hmac_hex_string(params[:sso]) == params[:sig]
  end

  def redirect_to_with_payload(url, payload)
    # Cross-host redirects are opt-in in Rails >= 6.1 (CVE-2020-15167 protection),
    # and the SSO handshake genuinely needs it: the payload travels to Discourse and
    # back again. But `return_sso_url` is taken from the peer's payload, so without a
    # check a peer that knows the shared secret (or a compromised/misconfigured
    # Discourse) could send a fresh payload -- with the user's email, name, username
    # and external id -- to any host it likes. So only redirect to known hosts.
    target = allowed_sso_url(url)
    raise I18n.t('discourse.redirect.invalid_url') if target.nil?

    base64_payload = Base64.strict_encode64 payload.to_query
    sso = CGI.escape base64_payload
    sig = get_hmac_hex_string base64_payload
    separator = target.query.present? ? '&' : '?'
    redirect_to "#{target}#{separator}sso=#{sso}&sig=#{sig}", allow_other_host: true
  end

  # Returns the URL as a URI when it points to a host allowed for the SSO handshake,
  # nil otherwise.
  #
  # Allowed are: this foodsoft instance (the login callback comes back here), the
  # configured +discourse_url+, and any extra hosts in the +discourse_redirect_hosts+
  # config (a String, or a list of Strings for co-ops with several Discourse installs,
  # e.g. [+https://forum.example.com+, +https://blog.example.net+]).
  #
  # Matching is exact on scheme://host[:port] -- subdomains are not implied.
  def allowed_sso_url(url)
    target = URI.parse(url.to_s.strip)
    return nil unless target.is_a?(URI::HTTP)
    return nil if target.host.nil? || target.userinfo || target.fragment

    return nil unless sso_redirect_origins.include?(target_origin(target))

    target
  rescue URI::InvalidURIError
    nil
  end

  # scheme://host[:port] in a single canonical form (default port dropped, host
  # lower-cased) so configured and requested origins compare equal.
  def target_origin(uri)
    port = uri.port == uri.default_port ? nil : uri.port
    "#{uri.scheme}://#{uri.host.downcase}#{':' + port.to_s if port}"
  end

  def sso_redirect_origins
    @sso_redirect_origins ||= [discourse_self_origin,
                               FoodsoftConfig[:discourse_url],
                               *Array.wrap(FoodsoftConfig[:discourse_redirect_hosts])]
                              .compact.map { |u| configured_origin(u) }.compact
  end

  # Origin of this foodsoft instance, so the SSO return trip to our own callback works.
  # When it can't be determined, fall back to the host of the current request.
  def discourse_self_origin
    root_url.to_s
  rescue StandardError
    request.nil? ? nil : "#{request.protocol}#{request.host_with_port}"
  end

  # Parse a configured URL into a canonical origin, nil when it isn't usable.
  def configured_origin(url)
    uri = URI.parse(url.to_s.strip)
    return nil unless uri.is_a?(URI::HTTP) && uri.host

    target_origin(uri)
  rescue URI::InvalidURIError
    nil
  end

  def parse_payload
    payload = Rack::Utils.parse_query Base64.decode64(params[:sso])
    payload.symbolize_keys!
  end

  def get_hmac_hex_string(payload)
    discourse_sso_secret = FoodsoftConfig[:discourse_sso_secret]
    OpenSSL::HMAC.hexdigest 'sha256', discourse_sso_secret, payload
  end
end
