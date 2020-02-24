require 'foodsoft_banks_austria/engine'

module FoodsoftBanksAustria
  ActiveSupport.on_load(:after_initialize) do
    require 'foodsoft_banks_austria/bank_account_connector_easybank'
    BankAccountConnector.register BankAccountConnectorEasybank

    require 'foodsoft_banks_austria/bank_account_connector_foodsoft'
    BankAccountConnector.register BankAccountConnectorFoodsoft

    require 'foodsoft_banks_austria/bank_account_connector_holvi'
    BankAccountConnector.register BankAccountConnectorHolvi

    require 'foodsoft_banks_austria/bank_account_connector_meinelba'
    BankAccountConnector.register BankAccountConnectorMeinelba

    require 'foodsoft_banks_austria/bank_account_connector_sparkasse'
    BankAccountConnector.register BankAccountConnectorSparkasse
  end
end
