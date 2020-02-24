require 'base_connector'

class HolviConnector < BaseConnector

  def login(email, password)
    data = {
      client_id: 'yIO3banxfsiuQSMrVg7x2LoKAqYKazRV',
      connection: 'Username-Password-Authentication',
      email: email,
      grant_type: 'password',
      password: password,
    }

    login_impl '/auth-proxy/login/usernamepassword/', data
  end

  def twofactor(token)
    path = "/auth-proxy/2fa/v1/token/#{token}/"
    res = get_api path
    @twofactor_short_code = res[:short_code]
    return false if res[:state] != 'activated'
    login_impl path + 'session/'
  end

  def logout
    get BASE_URL + '/logout/'
  end

  def balance(iban)
    item = summary iban
    return item[:account_balance] if item
  end

  def transactions(iban, from = nil, &block)
    item = summary iban
    return nil unless item

    items = []
    debt item[:handle] do |item|
      break if from && item[:timestamp] <= from
      next if item[:type] == 'invoice' && item[:status] != 'paid'

      entity = item[:receiver]
      entity = item[:sender] if item[:type] == 'iban_payment'

      amount = item[:value]
      amount = '-' + amount if item[:type] == 'outboundpayment'

      timestamp = item[:timestamp]
      message = item[:structured_reference] + item[:unstructured_reference]
      item[:items].each do |item|
        m = /^Payment with message (.*)$/.match(item[:description])
        message = m[1] if m
        timestamp = item[:timestamp] if item[:type] == 'settlement'
      end

      items << {
        id: item[:uuid],
        type: item[:type],
        timestamp: timestamp,
        amount: amount,
        name: entity[:name],
        iban: item[:iban] != iban ? item[:iban] : '',
        message: message
      }
    end

    items.sort_by! { |item| item[:timestamp] }
    items.each &block
    items.last && items.last[:timestamp]
  end

  def twofactor_short_code
    @twofactor_short_code
  end

  def twofactor_token_id
    @twofactor_token_id
  end

  private

  BASE_URL = 'https://holvi.com'

  def api_url(path)
    BASE_URL + '/api' + path
  end

  def post_api(path, data)
    post_json api_url(path), data
  end

  def get_api(path)
    get_json api_url(path)
  end

  def login_impl(path, data={})
    res = post_api path, data
    set_authorization_header res[:token_type], res[:id_token]

    token_meta = res[:token_meta]
    if token_meta
      @twofactor_token_id = token_meta[:twofactor_token_id]
      @twofactor_short_code = token_meta[:short_code]
    end

    res[:token_usage] == 'session'
  end

  def summary(iban)
    @summarylist = get_api('/pool/summarylist/') unless @summarylist

    @summarylist.each do |item|
      return item if item[:iban] == iban
    end

    nil
  end

  def debt(handle, page_size = 25)
    ret = get_api("/pool/#{handle}/debt/?o=-timestamp&page_size=#{page_size}")
    while ret do
      ret[:results].map do |item|
        yield item
      end
      ret = ret[:next] && get_json(ret[:next])
    end
  end

end
