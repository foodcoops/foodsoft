class BankAccountConnectorExternal < BankAccountConnector
  def load(data)
    @connector = create_connector
    @connector.load data
  end

  def dump
    @connector.dump
  end

  def connector_import
    set_balance @connector.balance iban
    cp = @connector.transactions iban, continuation_point do |t|
      update_or_create_transaction t[:id], map_transaction(t)
    end
    set_continuation_point cp if cp
  end

  def connector_logout
    @connector.logout
  end

  def import(data)
    return false unless connector_login(data)

    connector_import
    connector_logout
    true
  end
end
