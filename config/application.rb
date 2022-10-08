require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Foodsoft
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths << Rails.root.join('lib')

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # Internationalization.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.yml')]
    config.i18n.available_locales = Pathname.glob(Rails.root.join('config', 'locales', '{??,???}{-*,}.yml')).map { |p| p.basename('.yml').to_s }
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # TODO: Remove this. See CVE-2022-32224 for details.
    config.active_record.yaml_column_permitted_classes = [BigDecimal, Date, Symbol, Time]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # TODO Disable this. Uncommenting this line will currently cause rspec to fail.
    config.action_controller.permit_all_parameters = true

    config.active_job.queue_adapter     = :resque
    config.active_job.queue_name_prefix = ENV.fetch('JOB_QUEUE_PREFIX', "foodsoft_#{Rails.env}")

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # It would be nice not to enable database connection when precompiling assets,
    # but i18n-js requires initialization, that's why it's on.
    config.assets.initialize_on_precompile = true

    # Load legacy scripts from vendor
    config.assets.precompile += ['vendor/assets/javascripts/*.js']

    # CORS for API
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        # this restricts Foodsoft scopes to certain characters - let's discuss it when it becomes an actual problem
        resource %r{\A/[-a-zA-Z0-9_]+/api/v1/}, headers: :any, methods: :any
      end
    end
  end

  # Foodsoft version
  VERSION = Rails.root.join('VERSION').read.strip
  # Current revision, or +nil+
  REVISION = (Rails.root.join('REVISION').read.strip rescue nil)
end
