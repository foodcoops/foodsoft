raw_config = File.read(RAILS_ROOT + "/config/app_config.yml")
APP_CONFIG = YAML.load(raw_config)[RAILS_ENV].symbolize_keys

module Foodsoft
  @@configs = YAML.load(File.read(RAILS_ROOT + "/config/app_config.yml"))
  @@databases = YAML.load(File.read(RAILS_ROOT + "/config/database.yml"))
  @@env = RAILS_ENV

  def set_env(env)
    @@env = env
  end

  def config(rails_env = @@env)
    @@configs[rails_env].symbolize_keys
  end

  def database(rails_env = @@env)
    @@databases[rails_env].symbolize_keys
  end

  extend self
end


# Configuration of the exception_notification plugin
# Mailadresses are set in config/foodsoft.yaml
ExceptionNotifier.exception_recipients = APP_CONFIG[:notification]['error_recipients']
ExceptionNotifier.sender_address = APP_CONFIG[:notification]['sender_address']
ExceptionNotifier.email_prefix = APP_CONFIG[:notification]['email_prefix']