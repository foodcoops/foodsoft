require "foodsoft_pyapp/version"
require "foodsoft_pyapp/engine"

module FoodsoftPyapp
  def self.enabled?
    FoodsoftConfig[:use_pyapp]
  end
end
