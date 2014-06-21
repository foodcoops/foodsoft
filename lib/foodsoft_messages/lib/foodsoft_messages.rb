require "foodsoft_messages/engine"
require "foodsoft_messages/user_link"
require "deface"

module FoodsoftMessages
  # Return whether messages are used or not.
  # Enabled by default in {FoodsoftConfig} since it used to be part of the foodsoft core.
  def self.enabled?
    FoodsoftConfig[:use_messages]
  end
end
