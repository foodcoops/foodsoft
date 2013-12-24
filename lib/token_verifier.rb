class TokenVerifier < ActiveSupport::MessageVerifier

  def initialize(prefix)
    super(self.class.secret(prefix))
  end

  def generate(message='ok')
    super(message)
  end

  # def verify(message)

  protected

  def self.secret(prefix)
    prefix = [prefix] unless prefix.is_a?(Array)
    foodcoop = FoodsoftConfig.scope
    ([foodcoop, ':foodsoft'] + prefix + [':'+Foodsoft::Application.config.secret_token]).join(':')
  end

end
