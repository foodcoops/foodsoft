# Foodsoft production configuration.
#
# This file is in the public domain.

Foodsoft::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = ENV["RAILS_FORCE_SSL"] != "false"

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # https://github.com/heroku/rails_12factor/issues/25#issuecomment-231103483
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    STDOUT.sync      = true
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Configure hostname for action mailer (can be overridden in foodcoop config)
  config.action_mailer.default_url_options = { host: `hostname -f`, protocol: 'https' }

  if ENV['POSTMARK_API_KEY'].present?
       config.action_mailer.delivery_method = :postmark
       config.action_mailer.postmark_settings = { :api_token => ENV['POSTMARK_API_KEY'] }
  elsif ENV['SMTP_ADDRESS'].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { address: ENV['SMTP_ADDRESS'] }
    config.action_mailer.smtp_settings[:port] = ENV['SMTP_PORT'] if ENV['SMTP_PORT'].present?
    config.action_mailer.smtp_settings[:domain] = ENV['SMTP_DOMAIN'] if ENV['SMTP_DOMAIN'].present?
    config.action_mailer.smtp_settings[:user_name] = ENV['SMTP_USER_NAME'] if ENV['SMTP_USER_NAME'].present?
    config.action_mailer.smtp_settings[:password] = ENV['SMTP_PASSWORD'] if ENV['SMTP_PASSWORD'].present?
    config.action_mailer.smtp_settings[:authentication] = ENV['SMTP_AUTHENTICATION'] if ENV['SMTP_AUTHENTICATION'].present?
    config.action_mailer.smtp_settings[:enable_starttls_auto] = ENV['SMTP_ENABLE_STARTTLS_AUTO'] == 'true' if ENV['SMTP_ENABLE_STARTTLS_AUTO'].present?
    config.action_mailer.smtp_settings[:openssl_verify_mode] = ENV['SMTP_OPENSSL_VERIFY_MODE'] if ENV['SMTP_OPENSSL_VERIFY_MODE'].present?
  else
    # Use sendmail as default to avoid ssl cert problems
    config.action_mailer.delivery_method = :sendmail
  end

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new
end
