# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV["FOODSOFT_APP_CONFIG"] ||= 'spec/app_config.yml' # load special foodsoft config
require_relative 'support/coverage' # needs to be first
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/apparition'

Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :apparition

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # We use capybara with webkit, and need database_cleaner
  config.before(:each) do
    DatabaseCleaner.strategy = (RSpec.current_example.metadata[:js] ? :truncation : :transaction)
    DatabaseCleaner.start
    # clean slate mail queues, not sure why needed - https://github.com/rspec/rspec-rails/issues/661
    ActionMailer::Base.deliveries.clear
  end
  config.after(:each) do
    DatabaseCleaner.clean
    # Need to clear cache for RailsSettings::CachedSettings
    Rails.cache.clear
  end

  # reload foodsoft configuration, so that tests can use FoodsoftConfig.config[:foo]=x
  # without messing up tests run after that
  config.before(:each) do
    FoodsoftConfig.init
    FoodsoftConfig.init_mailing
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include SessionHelper, type: :feature

  # Automatically determine spec from directory structure, see:
  # https://www.relishapp.com/rspec/rspec-rails/v/3-0/docs/directory-structure
  config.infer_spec_type_from_file_location!
end

# include default foodsoft scope in urls, so that *_path works
# https://github.com/rspec/rspec-rails/issues/255
class ActionDispatch::Routing::RouteSet
  def default_url_options(options={})
      {foodcoop: FoodsoftConfig.scope}.merge(options)
  end
end
