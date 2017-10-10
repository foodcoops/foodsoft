# A sample Gemfile
source "https://rubygems.org"

gem "rails", '~> 4.2'


gem 'sass-rails'
gem 'less-rails'
gem 'uglifier', '>= 1.0.3'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby


gem 'jquery-rails'
gem 'select2-rails'
gem 'rails_tokeninput'
gem 'bootstrap-datepicker-rails'
gem 'date_time_attribute'
gem 'rails-assets-listjs', '0.2.0.beta.4' # remember to maintain list.*.js plugins and template engines on update
gem 'i18n-js', '~> 3.0.0.rc8'
gem 'rails-i18n'

gem 'mysql2'
gem 'prawn'
gem 'prawn-table'
gem 'haml-rails'
gem 'kaminari'
gem 'simple_form'
gem 'inherited_resources'
gem 'localize_input', git: "https://github.com/bennibu/localize_input.git"
gem 'daemons'
gem 'twitter-bootstrap-rails', '~> 2.2.8'
gem 'simple-navigation', '~> 3.14.0' # 3.x for simple_navigation_bootstrap
gem 'simple-navigation-bootstrap'
gem 'ransack'
gem 'acts_as_tree'
gem 'rails-settings-cached', '= 0.4.3' # caching breaks tests until Rails 5 https://github.com/huacnlee/rails-settings-cached/issues/73
gem 'resque'
gem 'whenever', require: false # For defining cronjobs, see config/schedule.rb
gem 'protected_attributes', '= 1.1.0' # 1.1.0 until tests work work with higher versions
gem 'ruby-units'
gem 'attribute_normalizer'
gem 'ice_cube'
gem 'recurring_select'
gem 'roo'
gem 'roo-xls'
gem 'spreadsheet'
gem 'gaffe'
gem 'ruby-filemagic'

# we use the git version of acts_as_versioned, and need to include it in this Gemfile
gem 'acts_as_versioned', git: 'https://github.com/technoweenie/acts_as_versioned.git'
gem 'foodsoft_wiki', path: 'plugins/wiki'
gem 'foodsoft_messages', path: 'plugins/messages'

# plugins not enabled by default
#gem 'foodsoft_current_orders', path: 'plugins/current_orders'
#gem 'foodsoft_uservoice', path: 'plugins/uservoice'
#gem 'foodsoft_documents', path: 'plugins/documents'


group :production do
  gem 'exception_notification'
end

group :development do
  gem 'sqlite3'
  gem 'mailcatcher'
  gem 'web-console', '~> 2.0'

  # allow to use `debugger` https://github.com/conradirwin/pry-rescue
  gem 'pry-rescue'
  gem 'pry-stack_explorer'

  # Better error output
  gem 'better_errors'
  gem 'binding_of_caller'
  # gem "rails-i18n-debug"
  # chrome debugging extension https://github.com/dejan/rails_panel
  gem 'meta_request'

  # Get infos when not using proper eager loading
  gem 'bullet'

  # Hide assets requests in log
  gem 'quiet_assets'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.2.0', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-bundler', '>= 1.1.0', require: false
  gem 'capistrano-rails', require: false
  # Avoid having content-length warnings
  gem 'thin'
end

group :development, :test do
  gem 'ruby-prof', require: false
end

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  gem 'connection_pool'
  # need to include rspec components before i18n-spec or rake fails in test environment
  gem 'rspec-core', '~> 3.2'
  gem 'rspec-rerun'
  gem 'i18n-spec'
  # code coverage
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end
