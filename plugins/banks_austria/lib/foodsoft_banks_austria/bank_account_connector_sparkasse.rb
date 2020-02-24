require 'sparkasse_connector'

module FoodsoftBanksAustria

  class BankAccountConnectorSparkasse < BankAccountConnectorExternal

    def create_connector
      SparkasseConnector.new
    end

    def self.handles(iban)
      /^AT\d{2}20111\d{11}$/.match(iban)
    end

    def map_transaction(t)
      {
        date: t[:bookingDate],
        amount: t[:amount],
        iban: t[:iban],
        reference: t[:text],
        text: t[:name],
      }
    end

    def connector_login(data)
      unless data
        config = FoodsoftConfig[:sparkasse]
        if config
          @connector.login config[:username]
          @connector.password config[:password]
          return true
        end

        text_field :username
        return
      end

      if data[:username]
        case @connector.login(data[:username])
        when :password then
          password_field :password
        when :twofactor then
          wait_for_app @connector.twofactor_short_code
        end
        return
      end

      if data[:password]
        @connector.password(data[:password])
      end

      if data[:twofactor]
        unless @connector.twofactor(data[:twofactor])
          return wait_for_app data[:twofactor]
        end
      end

      true
    end
  end

end
