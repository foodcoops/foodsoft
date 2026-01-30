# A sample Gemfile
source 'https://rubygems.org'

gem 'rails', '~> 7.2.2'

gem 'sassc-rails', '>= 2.1.0'

gem 'bootsnap', require: false
gem 'bootstrap-datepicker-rails'
gem 'date_time_attribute'
gem 'i18n-js', '~> 3.0.0.rc8'
gem 'jquery-rails'
gem 'rails-assets-listjs', '0.2.0.beta.4' # remember to maintain list.*.js plugins and template engines on update
gem 'rails-i18n'
gem 'rails_tokeninput'
gem 'select2-rails'

gem 'active_model_serializers', '~> 0.10.0'
gem 'acts_as_tree'
gem 'attribute_normalizer'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'daemons'
gem 'doorkeeper'
gem 'doorkeeper-i18n'
gem 'font-awesome-rails'
gem 'haml', '~> 5.2', '>= 5.2.2'
gem 'haml-rails'
gem 'ice_cube'
gem 'inherited_resources'
gem 'kaminari'
gem 'mysql2'
gem 'net-ftp'
gem 'net-http'
gem 'prawn'
gem 'prawn-table'
gem 'puma'
gem 'rack-cors', require: 'rack/cors'
gem 'rails-settings-cached', '= 0.4.3' # caching breaks tests until Rails 5 https://github.com/huacnlee/rails-settings-cached/issues/73
gem 'ransack'
gem 'resque'
gem 'simple_form'
gem 'simple-navigation'
gem 'simple_navigation_bootstrap'
gem 'sprockets', '< 4'
gem 'whenever', require: false # For defining cronjobs, see config/schedule.rb
# At time of development 01-06-2022 mmddyyyy necessary fix for config_helper.rb form builder was not in rubygems so we pull from github, see: https://github.com/gregschmit/recurring_select/pull/152
gem 'concurrent-ruby', '1.3.4'
gem 'csv'
gem 'exception_notification'
gem 'gaffe'
gem 'hashie', '~> 3.4.6', require: false # https://github.com/westfieldlabs/apivore/issues/114
gem 'image_processing', '~> 1.12'
gem 'importmap-rails', '~> 1.1'
gem 'midi-smtp-server'
gem 'mime-types'
gem 'mutex_m'
gem 'psych', '3.3.2'
gem 'recurring_select', git: 'https://github.com/gregschmit/recurring_select'
gem 'roo'
gem 'roo-xls'
gem 'rswag-api'
gem 'rswag-ui'
gem 'ruby-filemagic'
gem 'spreadsheet'
gem 'terser', '~> 1.1'

# we use a fork with Ruby 3 support of acts_as_versioned, and need to include it in this Gemfile
gem 'acts_as_versioned', git: 'https://github.com/assembla/acts_as_versioned.git'
gem 'foodsoft_discourse', path: 'plugins/discourse'
gem 'foodsoft_documents', path: 'plugins/documents'
gem 'foodsoft_links', path: 'plugins/links'
gem 'foodsoft_messages', path: 'plugins/messages'
gem 'foodsoft_polls', path: 'plugins/polls'
gem 'foodsoft_wiki', path: 'plugins/wiki'

# plugins not enabled by default
# gem 'foodsoft_b85', path: 'plugins/b85'
# gem 'foodsoft_current_orders', path: 'plugins/current_orders'
# gem 'foodsoft_printer', path: 'plugins/printer'
# gem 'foodsoft_uservoice', path: 'plugins/uservoice'
# gem 'foodsoft_mollie', path: 'plugins/mollie'

group :development do
  gem 'listen'
  gem 'mailcatcher'
  gem 'sqlite3', '~> 2.7'
  gem 'web-console'

  # Better error output
  gem 'better_errors'
  gem 'binding_of_caller'
  # gem "rails-i18n-debug"
  # chrome debugging extension https://github.com/dejan/rails_panel
  # TODO: disabled due to https://github.com/rails/rails/issues/40781
  # gem 'meta_request'

  # Get infos when not using proper eager loading
  gem 'bullet'
  # Display Active Record queries as tables in the console
  gem 'table_print'
end

group :development, :test do
  gem 'rails-erd', '~> 1.7'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'ruby-prof', require: false

  # allow to use `debugger` https://github.com/conradirwin/pry-rescue
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'apparition' # Capybara javascript driver
  gem 'capybara'
  gem 'connection_pool'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  # need to include rspec components before i18n-spec or rake fails in test environment
  gem 'i18n-spec'
  gem 'rspec-core'
  gem 'rspec-rerun'
  # code coverage
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  # api
  gem 'rswag-specs'
  # plugins with tests deactivated by default
  gem 'foodsoft_b85', path: 'plugins/b85'
end
