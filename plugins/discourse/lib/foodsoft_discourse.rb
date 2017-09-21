require 'foodsoft_discourse/engine'
require 'foodsoft_discourse/redirect_to_login'

module FoodsoftDiscourse
  def self.enabled?
    FoodsoftConfig[:discourse_url] && FoodsoftConfig[:discourse_sso_secret]
  end
end
