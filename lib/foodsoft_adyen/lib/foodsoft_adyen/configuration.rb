module FoodsoftAdyen
  class Configuration
    def initialize
      @currency = 'EUR'
      @notificy_username = nil
      @notificy_password = nil
    end

    attr_accessor :currency
    attr_accessor :notify_username
    attr_accessor :notify_password
  end
end
