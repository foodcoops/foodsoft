# A sample Gemfile
source "https://rubygems.org"
ruby "2.0.0"

gem "rails", '~> 4.0.0'


gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'less-rails'
gem 'uglifier', '>= 1.0.3'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby


gem 'jquery-rails'
gem 'select2-rails'
gem 'bootstrap-datepicker-rails'
gem 'date_time_attribute'
gem 'rails-assets-listjs', '0.2.0.beta.4' # remember to maintain list.*.js plugins and template engines on update
gem 'i18n-js', git: 'git://github.com/fnando/i18n-js.git' # to avoid US-ASCII js.erb error
gem 'rails-i18n'

gem 'mysql2'
gem 'prawn'
gem 'haml-rails'
gem 'kaminari'
gem 'simple_form'
gem 'client_side_validations', git: 'git://github.com/bcardarella/client_side_validations.git', branch: '4-0-beta'
gem 'client_side_validations-simple_form', git: 'git://github.com/saveritemedical/client_side_validations-simple_form.git'
gem 'inherited_resources'
gem 'localize_input', git: "git://github.com/bennibu/localize_input.git"
gem 'daemons'
gem 'twitter-bootstrap-rails'
gem 'simple-navigation'
gem 'simple-navigation-bootstrap'
gem 'ransack'
gem 'acts_as_tree'
gem "rails-settings-cached", "0.3.1"
gem 'resque'
gem 'whenever', require: false # For defining cronjobs, see config/schedule.rb
gem 'protected_attributes'
gem 'ruby-units'

# we use the git version of acts_as_versioned, and need to include it in this Gemfile
gem 'acts_as_versioned', git: 'git://github.com/technoweenie/acts_as_versioned.git'
gem 'foodsoft_wiki', path: 'lib/foodsoft_wiki'
gem 'foodsoft_messages', path: 'lib/foodsoft_messages'

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'sqlite3'
  gem 'mailcatcher'
  
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
  gem 'yard-activerecord', require: false
  #gem 'yard-rails-plugin', github: 'ogeidix/yard-rails-plugin', tag: 'v0.0.1', require: false
end

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'capybara'
  # webkit and poltergeist don't seem to work yet
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'connection_pool'
  # need to include rspec components before i18n-spec or rake fails in test environment
  gem 'rspec-core', '= 2.14.8' # version until we're ready for rspec 3.0
  gem 'rspec-expectations'
  gem 'rspec-rerun'
  gem 'i18n-spec'
  # code coverage
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end
