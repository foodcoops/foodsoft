# Loads and returns config and databases for selected foodcoop.
module Foodsoft
  @@configs = YAML.load(File.read(RAILS_ROOT + "/config/app_config.yml"))
  @@databases = YAML.load(File.read(RAILS_ROOT + "/config/database.yml"))
  @@env = RAILS_ENV

  def env=(env)
    @@env = env
  end

  def env
    @@env
  end

  def config(rails_env = @@env)
    raise "No config for this environment (or subdomain) available!" if @@configs[rails_env].nil?
    @@configs[rails_env].symbolize_keys
  end

  def database(rails_env = @@env)
    raise "No database for this environment (or subdomain) available!" if @@databases[rails_env].nil?
    @@databases[rails_env].symbolize_keys
  end

  extend self
end


# Configuration of the exception_notification plugin
# Mailadresses are set in config/foodsoft.yaml
ExceptionNotifier.exception_recipients = Foodsoft.config[:notification]['error_recipients']
ExceptionNotifier.sender_address = Foodsoft.config[:notification]['sender_address']
ExceptionNotifier.email_prefix = Foodsoft.config[:notification]['email_prefix']