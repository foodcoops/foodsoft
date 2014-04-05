require "foodsoft_messages/engine"
require "foodsoft_messages/user_link"
require "deface"

module FoodsoftMessages
  # Return whether messages are used or not.
  # Enabled by default since it used to be part of the foodsoft core.
  def self.enabled?
    FoodsoftConfig[:use_messages] != false
  end
end
