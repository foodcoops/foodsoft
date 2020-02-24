require 'meinelba_connector'

module FoodsoftBanksAustria

  class BankAccountConnectorMeinelba < BankAccountConnectorExternal

    def create_connector
      MeinelbaConnector.new
    end

    def self.handles(iban)
      /^AT\d{2}3\d{15}$/.match(iban)
    end

    def map_transaction(t)
      {
        date: t[:date],
        amount: t[:amount],
        iban: t[:iban],
        reference: t[:text],
        text: t[:name],
      }
    end

    def connector_login(data)
      unless data
        text_field :username
        password_field :pin
        return
      end

      if data[:username]
        type = @connector.login data[:username], data[:pin]
        hidden_field :signature_id, @connector.signature_id
        return wait_for_app @connector.display_text if type == :pushtan
        hidden_field :pin_hash, @connector.pin_hash
        confirm_text @connector.display_text
        text_field :tan
        return
      end

      if data[:twofactor]
        unless @connector.pushtan(data[:signature_id], data[:twofactor])
          hidden_field :signature_id, data[:signature_id]
          return wait_for_app data[:twofactor]
        end
      else
        return @connector.smstan data[:signature_id], data[:pin_hash], data[:tan]
      end

      true
    end
  end

end
