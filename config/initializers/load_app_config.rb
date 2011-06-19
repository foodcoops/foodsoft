# Loads and returns config and databases for selected foodcoop.
# TODO: When to use class or module. It seems this could also be a Foodsoft-class?
module Foodsoft
  mattr_accessor :env, :config, :database
  CONFIGS = YAML.load(File.read(File.join(Rails.root, "/config/app_config.yml")))
  DATABASES = YAML.load(File.read(File.join(Rails.root, "/config/database.yml")))

  class << self
    def env=(env)
      raise "No config or database for this environment (#{env}) available!" if CONFIGS[env].nil? or DATABASES[env].nil?
      @@config = CONFIGS[env].symbolize_keys
      @@database = DATABASES[env].symbolize_keys
      @@env = env
    end
  end
end
# Initial load the default config and database from rails environment
Foodsoft.env = Rails.env

# Set action mailer default host for url generating
url_options = {
    :host => Foodsoft.config[:host],
    :protocol => Foodsoft.config[:protocol]
}
url_options.merge!({:port => Foodsoft.config[:port]}) if Foodsoft.config[:port]

Foodsoft::Application.configure do
  config.action_mailer.default_url_options = url_options
  
  if Rails.env !~ /development|test/
    # Configuration of the exception_notification plugin
    # Mailadresses are set in config/app_config.yml
    config.middleware.use ExceptionNotifier,
                          :email_prefix => Foodsoft.config[:notification]['email_prefix'],
                          :sender_address => Foodsoft.config[:notification]['sender_address'],
                          :exception_recipients => Foodsoft.config[:notification]['error_recipients']
  end
end

