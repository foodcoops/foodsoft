require 'oauth2'

module FoodsoftBanksAustria

  class BankAccountConnectorFoodsoft < BankAccountConnector

    def self.handles(iban)
      iban == 'ZZ99FOODSOFT'
    end

    def import(data)
      foodsoft_config = FoodsoftConfig[:foodsoft]
      raise 'foodsoft configuration missing' unless foodsoft_config

      client_id = foodsoft_config[:client_id]
      client_secret = foodsoft_config[:client_secret]
      site = foodsoft_config[:site]
      slug = foodsoft_config[:slug]
      username = foodsoft_config[:username]
      password = foodsoft_config[:password]

      client = OAuth2::Client.new(client_id, client_secret, site: site, token_url: "/#{slug}/oauth/token")
      token = client.password.get_token(username, password)
      response = token.get("#{site}/#{slug}/api/v1/user/financial_transactions?per_page=100&q[id_gt]=#{continuation_point}")
      result = JSON.parse response.body, symbolize_names: true

      cp = 0

      result[:financial_transactions].each do |t|
        update_or_create_transaction t[:id],
          date: t[:created_at],
          amount: t[:amount],
          text: t[:financial_transaction_type_name],
          reference: t[:note]

        cp = [cp, t[:id]].max
      end

      set_balance_as_sum
      set_continuation_point cp if cp
      true
    end

  end

end
