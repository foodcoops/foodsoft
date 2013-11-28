module FoodsoftAdyen
  class Engine < ::Rails::Engine
    require 'jquery_mobile_rails' # http://stackoverflow.com/questions/12256291

    # make sure assets we include in our engine only are precompiled too
    initializer 'foodsoft_adyen.assets', :group => :all do |app|
      app.config.assets.precompile += %w(payments/adyen_mobile.css payments/adyen_mobile.js)
    end

    # add to existing navigation
    def navigation(primary, context)
      return if primary[:finance].nil?
      primary[:finance].sub_navigation.items <<
        SimpleNavigation::Item.new(primary, :pin_terminal, I18n.t('payments.navigation.pin'), context.payments_adyen_pin_path)
    end
  end
end
