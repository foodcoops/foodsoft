require 'foodsoft_invoices/engine'
require 'deface'

module FoodsoftInvoices
  # Return whether invoices are used or not.
  # Disabled by default in {FoodsoftConfig}.
  def self.enabled?
    FoodsoftConfig[:use_invoices]
  end
end
