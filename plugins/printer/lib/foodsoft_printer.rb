require 'foodsoft_printer/engine'
require 'foodsoft_printer/order_printer_jobs'
require 'tubesock'

module FoodsoftPrinter
  def self.enabled?
    FoodsoftConfig[:use_printer]
  end
end
