# Initial load the default config and database from rails environment
# See config/app_config.yml for further details
# Load Config, start by selecting defaults via current environment
require 'foodsoft_config'
FoodsoftConfig.init

Foodsoft::Application.configure do
  # Set action mailer default host for url generating
  [:protocol, :host, :port].each do |k|
    config.action_mailer.default_url_options[k] = FoodsoftConfig[k] if FoodsoftConfig[k]
  end
  
  if %w(production).include? Rails.env 
    # Configuration of the exception_notification plugin
    # Mailadresses are set in config/app_config.yml
    config.middleware.use ExceptionNotification::Rack,
                          :email => {
                            :email_prefix => FoodsoftConfig[:notification]['email_prefix'],
                            :sender_address => FoodsoftConfig[:notification]['sender_address'],
                            :exception_recipients => FoodsoftConfig[:notification]['error_recipients']
                          }
  end
end

