# require 'Mollie/API/Client'
require 'mollie-api-ruby'
require 'foodsoft_mollie/engine'

module FoodsoftMollie
  # Enabled when configured, but can still be disabled by +use_mollie+ option.
  def self.enabled?
    FoodsoftConfig[:use_mollie] != false and FoodsoftConfig[:mollie]
  end

  def self.currency
    FoodsoftConfig[:mollie][:currency] || 'EUR'
  end

  def self.charge_fees?
    FoodsoftConfig[:mollie][:charge_fees] && currency == 'EUR' # Mollie API returns fee's only in EUR
  end

  def self.default_amount
    FoodsoftConfig[:mollie][:default_amount] || 10
  end

  def self.api_key
    FoodsoftConfig[:mollie][:api_key]
  end
end
