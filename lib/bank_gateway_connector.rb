class BankGatewayConnector
  def initialize(bank_gateway)
    @bank_gateway = bank_gateway
  end

  def import_unattended
    res = http_post nil, nil, nil, false
    handle_result res.body
  end

  def pay_and_import_url(callback_uri, user, payments, reconfigure: false)
    res = http_post callback_uri, user, payments, reconfigure
    res.header['Location']
  end

  def handle_callback(params)
    res = http_get(params[:result])
    handle_result res.body
  end

  private

  def handle_result(content)
    return nil if content.empty?

    ret = 0

    data = JSON.parse content, symbolize_names: true

    result = data.fetch(:result, [])
    result.each do |t|
      iban = t.fetch(:account, {}).fetch(:iban)

      ba = BankAccount.find_by_iban iban
      raise "Unknown BankAccount" unless ba

      baii = BankAccountInformationImporter.new(ba)
      ret += baii.import_data! t
    end

    ret
  end

  def http_post(callback_uri, user, payments, reconfigure)
    data = {
      accounts: @bank_gateway.bank_accounts.map do |ba|
        {
          iban: ba.iban,
          dateFrom: ba.import_continuation_point && ba.last_transaction_date,
          dateTo: '9999-12-31',
          entryReferenceFrom: ba.import_continuation_point
        }
      end
    }
    data[:callbackUri] = callback_uri if callback_uri
    data[:payments] = payments if payments
    data[:user] = user.id.to_s if user
    data[:reconfigure] = true if reconfigure

    http_request { |http| http.post('/', data.to_json, 'Authorization' => @bank_gateway.authorization, 'Content-Type' => 'application/json') }
  end

  def http_get(path)
    http_request { |http| http.get(path, 'Authorization' => @bank_gateway.authorization) }
  end

  def http_request(&block)
    url = URI(@bank_gateway.url)
    ret = Net::HTTP.start(url.hostname, url.port, use_ssl: url.scheme == 'https', &block)
    if ret.code.to_i >= 400
      message = ret.message
      begin
        details = JSON.parse(ret.body, symbolize_names: true)[:message]
      rescue
        details = ''
      end
      message = "#{message}: #{details}" if details
      raise message
    end

    ret
  end
end
