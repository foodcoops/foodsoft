# Generic token verifier with foodcoop scope
# @todo use +Rails.application.message_verifier+ when possible
class TokenVerifier < ActiveSupport::MessageVerifier

  def initialize(prefix)
    super(self.class.secret)
    @_prefix = prefix.is_a?(Array) ? prefix.join(':') : prefix.to_s
  end

  def generate(message=nil)
    fullmessage = [FoodsoftConfig.scope, @_prefix]
    fullmessage.append(message) unless message.nil?
    super(fullmessage)
  end

  def verify(message)
    r = super(message)
    raise InvalidMessage unless r.is_a?(Array) && r.length >= 2 && r.length <= 3
    raise InvalidScope unless r[0] == FoodsoftConfig.scope
    raise InvalidPrefix unless r[1] == @_prefix
    # return original message
    if r.length > 2
      r[2]
    else
      nil
    end
  end

  class InvalidMessage < ActiveSupport::MessageVerifier::InvalidSignature; end
  class InvalidScope < ActiveSupport::MessageVerifier::InvalidSignature; end
  class InvalidPrefix < ActiveSupport::MessageVerifier::InvalidSignature; end

  protected

  def self.secret
    # secret_key_base for Rails 4, but Rails 3 initializer may still be used
    Foodsoft::Application.config.secret_key_base || Foodsoft::Application.config.secret_token
  end

end
