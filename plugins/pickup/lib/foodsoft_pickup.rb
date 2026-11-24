require 'foodsoft_pickup/engine'

module FoodsoftPickup
  # Return whether the pickup API is used or not.
  #
  # Off by default: this adds API endpoints, so an installation has to opt in
  # deliberately (it is a new attack surface even though it only reads data
  # that the foodcoop's own members may see anyway).
  def self.enabled?
    FoodsoftConfig[:use_pickup]
  end
end
