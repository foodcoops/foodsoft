require 'adyen'
require 'foodsoft_adyen/engine'
require 'foodsoft_adyen/configuration'
require 'foodsoft_adyen/railtie'

module FoodsoftAdyen
  def self.configuration
    @configuration ||= FoodsoftAdyen::Configuration.new
  end
end
