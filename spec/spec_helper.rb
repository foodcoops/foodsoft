# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ENV["FOODSOFT_APP_CONFIG"] ||= 'spec/app_config.yml' # load special foodsoft config
require_relative 'support/coverage' # needs to be first
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'capybara/rails'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true
  # We use capybara with selenium, and need database_cleaner
  config.before(:each) do
    DatabaseCleaner.strategy = (example.metadata[:js] ? :truncation : :transaction)
    DatabaseCleaner.start
    # maximise window so that buttons can be found on popups
    example.metadata[:js] and page.driver.browser.manage.window.maximize
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

  # reload foodsoft configuration, so that tests can use FoodsoftConfig.config[:foo]=x
  # without messing up tests run after that
  config.before(:each) do
    FoodsoftConfig.send :reload!
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

  config.include SessionHelper
end

module Faker
  class Unit
    class << self
      def unit
        ['kg', '1L', '100ml', 'piece', 'bunch', '500g'].sample
      end
    end
  end
end

# include default foodsoft scope in urls, so that *_path works
ActionDispatch::Integration::Runner.class_eval do
  undef default_url_options
  def default_url_options(options={})
      {foodcoop: FoodsoftConfig.scope}.merge(options)
  end
end
