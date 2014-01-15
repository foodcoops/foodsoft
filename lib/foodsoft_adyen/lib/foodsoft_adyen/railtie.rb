require 'rails'

module FoodsoftAdyen
  class Railtie < ::Rails::Railtie
    config.before_configuration do
      config.foodsoft_adyen = FoodsoftAdyen.configuration
    end
  end
end
