require 'holvi_connector'

module FoodsoftBanksAustria

  class BankAccountConnectorHolvi < BankAccountConnectorExternal

    def create_connector
      HolviConnector.new
    end

    def self.handles(iban)
      /^FI\d{2}799779\d{7}[0-9A-Z]$/.match(iban)
    end

    def map_transaction(t)
      {
        date: t[:timestamp],
        amount: t[:amount],
        iban: t[:iban],
        reference: t[:message],
        text: t[:name],
      }
    end

    def connector_login(data)
      unless data
        config = FoodsoftConfig[:holvi]
        if config
          @connector.login config[:username], config[:password]
          return true
        end

        text_field :email
        password_field :password
        return
      end

      if data[:email] && !@connector.login(data[:email], data[:password])
        return wait_for_app @connector.twofactor_token_id
      end

      if data[:twofactor] && !@connector.twofactor(data[:twofactor])
        return wait_for_app data[:twofactor]
      end

      true
    end
  end

end
