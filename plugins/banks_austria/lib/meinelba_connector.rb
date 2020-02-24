require 'base_connector'

class MeinelbaConnector < BaseConnector

  def login(user, pin)
    page = get START_URL
    m = /window\.location\s*=\s*'(?<url>[^']*)'/.match(page.body)
    page = get m['url'].gsub('\\/', '/').gsub('\\x26', '&').gsub('\\-', '-')

    loginForm = page.forms()[0]
    loginForm.submit nil, { 'Origin' => SSO_BASE_URL }

    post_login_api 'identify/' + format_user(user), nil

    @pin_hash = Digest::SHA256.hexdigest(pin)
    res = post_login_api 'login/pin', {
      verfuegerNr: format_user(user),
      pinHash: @pin_hash,
      bankengruppe: 'rbg',
      numericPin: true
    }

    if res[:challengeType] == 'PUSH'
      login_path = 'login/pushtan'
      ret = :pushtan
    elsif res[:challengeType] == 'SMSPIN'
      login_path = 'login/smstan'
      ret = :smstan
    else
      return
    end

    res = post_login_api login_path
    @signature_id = res[:signaturId]
    @display_text = res[:displayText]
    ret
  end

  def pushtan(signature_id, tan)
    res = get_login_api 'login/pushtan/' + signature_id
    return false unless res[:loggedIn]
    finish_login
  end

  def smstan(signature_id, pin_hash, tan)
    put_login_api 'login/smstan/' + signature_id, {
      pin: pin_hash,
      smsTAN: tan
    }
    finish_login
  end

  def finish_login()
    res = post_login_api 'login', {
      updateSession: false,
      accounts: nil
    }

    page = get res[:resumeUrl]
    get page.header['location']

    set_access_token_from_location_header get(SSO_BASE_URL + '/as/authorization.oauth2', {
      response_type: 'token',
      client_id: 'DRB-PFP-RBG',
      scope: 'edit',
      redirect_uri: START_URL,
      state: SecureRandom.hex(52)
    })
  end

  def pin_hash
    @pin_hash
  end

  def signature_id
    @signature_id
  end

  def display_text
    @display_text
  end

  def logout
    get SSO_BASE_URL + '/idp/startSLO.ping'
  end

  def balance(iban)
    res = get_api('pfp-konto/konto-ui-services/rest/kontobetraege', {
      iban: iban
    })
    item = res[iban.to_sym]
    return item[:kontostand][:amount] if item
  end

  def transactions(iban, from = nil, &block)
    token = (from || '').split('@')

    umsaetze = post_api('pfp-umsatz/umsatz-ui-services/rest/umsatz-page-fragment/umsaetze', {
      predicate: {
        ibans: [iban],
        buchungVon: token[1]
      }
    })
    items = []
    umsaetze.each do |item|
      next if token[0] && item[:id] <= token[0].to_i

      name = item[:transaktionsteilnehmerZeile1]
      name += "\n" + item[:transaktionsteilnehmerZeile2]
      name += "\n" + item[:transaktionsteilnehmerZeile3]
      name = name.strip()

      text = item[:zahlungsreferenz]
      text += "\n" + item[:verwendungszweckZeile1]
      text += "\n" + item[:verwendungszweckZeile2]
      text = text.strip()

      iban = item[:auftraggeberIban] || ''
      iban = iban.strip()
      iban = nil if iban.empty?

      items << {
        id: item[:id],
        date: item[:buchungstag],
        amount: item[:betrag] ? item[:betrag][:amount] : 0,
        name: name,
        iban: iban,
        text: text
      }
    end

    items.sort_by! { |item| item[:date] }
    items.each &block
    items.last && ("#{items.last[:id]}@#{items.last[:date]}T00:00:00")
  end

  private

  SSO_BASE_URL = 'https://sso.raiffeisen.at'
  START_URL = 'https://mein.elba.raiffeisen.at/pfp-widgetsystem/'

  def api_url(path)
    "https://mein.elba.raiffeisen.at/api/#{path}"
  end

  def login_api_url(path)
    "#{SSO_BASE_URL}/api/quer-kunde-login/kunde-login-ui-services/rest/#{path}"
  end

  def post_api(path, data)
    post_json api_url(path), data
  end

  def get_api(path, data=[])
    get_json api_url(path), data
  end

  def post_login_api(path, data={})
    post_json login_api_url(path), data
  end

  def put_login_api(path, data={})
    put_json login_api_url(path), data
  end

  def get_login_api(path)
    get_json login_api_url(path)
  end

  def format_user(user)
    user.upcase.gsub('-', '')
  end

end
