module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def self.broadcasting
      "#{FoodsoftConfig.scope}::#{self.name}"
    end
  end
end
