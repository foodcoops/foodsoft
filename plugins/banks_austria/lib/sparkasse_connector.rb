require 'base_connector'

class SparkasseConnector < BaseConnector

  def login(username)
    get LOGIN_OAUTH_URL

    page = post LOGIN_OAUTH_URL, j_username: username, javaScript: 'jsOK'

    commontext_b = page.search('.commontext > b')[1]
    loginForm = page.form_with(name: 'anmelden')

    if commontext_b
      @twofactor_short_code = commontext_b.content
      return :twofactor
    end

    if loginForm
      save_form loginForm
      return :password
    end
  end

  def password(password)
    exponent = saved_form_field 'exponent'
    modulus = saved_form_field 'modulus'
    saltCode = saved_form_field 'saltCode'

    rsa = OpenSSL::PKey::RSA.new
    rsa.set_key(OpenSSL::BN.new(modulus.to_i(16)), OpenSSL::BN.new(exponent.to_i(16)), nil)
    encrypted = rsa.public_encrypt("#{saltCode}\t#{password}")
    rsaEncrypted = encrypted.unpack("H*").join.upcase

    finish_login rsaEncrypted: rsaEncrypted, saltCode: saltCode
  end

  def twofactor(token)
    res = post_json LOGIN_SECAPP_URL
    return false if res[:secondFactorStatus] != 'DONE'
    finish_login
  end

  def logout
    delete 'https://api.sparkasse.at/rest/netbanking/auth/token/invalidate'
  end

  def balance(iban)
    item = account iban
    return amount(item[:balance]) if item
  end

  def transactions(iban, from = nil, &block)
    item = account iban
    return nil unless item
    acountId = item[:id]

    items = []

    page = 0
    loop do
      result = get_api("transactions?pageSize=50&suggest=true&page=#{page}&id=#{acountId}")
      collection = result[:collection]
      break if collection.empty?

      collection.each do |item|
        if from && item[:id] <= from
          page = -1
          break
        end

        text = item[:receiverReference]
        text = item[:senderReference] if text.empty?
        text = item[:subtitle] if text.empty?

        items << {
          id: item[:id],
          type: item[:bookingType],
          bookingDate: Time.at(item[:bookingDate] / 1000).to_date.to_s,
          amount: amount(item[:amount]),
          name: item[:title],
          iban: item[:partner][:iban],
          text: text
        }
      end

      break if page < 0
      page += 1
    end

    items.sort_by! { |item| item[:bookingDate] }
    items.each &block
    items.last && items.last[:id]
  end

  def twofactor_short_code
    @twofactor_short_code
  end

  private

  LOGIN_BASE_URL = 'https://login.sparkasse.at/sts'
  LOGIN_OAUTH_URL = LOGIN_BASE_URL + '/oauth/authorize?client_id=georgeclient&response_type=token'
  LOGIN_SECAPP_URL = LOGIN_BASE_URL + '/secapp/secondfactor?client_id=georgeclient'

  def amount(value)
    value[:value] / 10.0 ** value[:precision]
  end

  def finish_login(data={})
    set_access_token_from_location_header post(LOGIN_OAUTH_URL, data)
  end

  def get_api(path)
    get_json "https://api.sparkasse.at/proxy/g/api/my/#{path}"
  end

  def account(iban)
    @accounts = get_api('accounts') unless @accounts

    @accounts[:collection].each do |item|
      return item if item[:accountno][:iban] == iban
    end

    nil
  end

end
