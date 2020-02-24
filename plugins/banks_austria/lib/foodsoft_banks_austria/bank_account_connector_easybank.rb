require 'easybank_connector'

module FoodsoftBanksAustria

  class BankAccountConnectorEasybank < BankAccountConnectorExternal

    def create_connector
      EasybankConnector.new
    end

    def self.handles(iban)
      /^AT\d{2}14200\d{11}$/.match(iban)
    end

    def map_transaction(t)
      {
        date: t[:booking_date],
        amount: t[:amount],
        iban: t[:iban],
        reference: t[:reference] ? t[:reference] : t[:reference2],
        text: t[:raw],
        receipt: t[:receipt],
        image: t[:image],
      }
    end

    def connector_login(data)
      unless data
        config = FoodsoftConfig[:easybank]
        if config
          @connector.login config[:dn], config[:pin]
          return true
        end

        text_field :username
        password_field :pin
        return
      end

      @connector.login data[:username], data[:pin]
    end
  end

end
