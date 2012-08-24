# Initial load the default config and database from rails environment
# See config/app_config.yml for further details
# Load Config, start by selecting defaults via current environment
require 'foodsoft_config'
FoodsoftConfig.init

# Set action mailer default host for url generating
url_options = {
    :host => FoodsoftConfig[:host],
    :protocol => FoodsoftConfig[:protocol]
}
url_options.merge!({:port => FoodsoftConfig[:port]}) if FoodsoftConfig[:port]

Foodsoft::Application.configure do
  config.action_mailer.default_url_options = url_options
  
  if Rails.env !~ /development|test/
    # Configuration of the exception_notification plugin
    # Mailadresses are set in config/app_config.yml
    config.middleware.use ExceptionNotifier,
                          :email_prefix => FoodsoftConfig[:notification]['email_prefix'],
                          :sender_address => FoodsoftConfig[:notification]['sender_address'],
                          :exception_recipients => FoodsoftConfig[:notification]['error_recipients']
  end
end

