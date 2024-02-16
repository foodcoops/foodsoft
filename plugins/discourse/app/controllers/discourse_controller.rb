class DiscourseController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftDiscourse }

  protected

  def valid_signature?
    return false if params[:sso].blank? || params[:sig].blank?

    get_hmac_hex_string(params[:sso]) == params[:sig]
  end

  def redirect_to_with_payload(url, payload)
    base64_payload = Base64.strict_encode64 payload.to_query
    sso = CGI.escape base64_payload
    sig = get_hmac_hex_string base64_payload

                             
    redirect_to "#{url}#{url.include?('?') ? '&' : '?'}sso=#{sso}&sig=#{sig}", allow_other_host: true
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
