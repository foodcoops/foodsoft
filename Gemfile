# A sample Gemfile
source "https://rubygems.org"
ruby "1.9.3"

gem "rails", '~> 3.2.9'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', platforms: :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'select2-rails'
gem 'bootstrap-datepicker-rails'


gem 'mysql2'
gem 'prawn'
gem 'haml-rails'
gem 'kaminari'
gem 'client_side_validations'
gem 'simple_form'
gem 'inherited_resources'
gem 'localize_input', git: "git://github.com/bennibu/localize_input.git"
gem 'wikicloth'
gem 'daemons'
gem 'twitter-bootstrap-rails'
gem 'simple-navigation'
gem 'simple-navigation-bootstrap'
gem 'meta_search'
gem 'acts_as_versioned', git: 'git://github.com/technoweenie/acts_as_versioned.git' # Use this instead of rubygem
gem 'acts_as_tree'
gem 'acts_as_configurable', git: 'git://github.com/bwalding/acts_as_configurable.git'
gem 'resque'
gem 'whenever', require: false # For defining cronjobs, see config/schedule.rb

group :production do
  gem 'exception_notification', require: 'exception_notifier'
end

group :development do
  gem 'sqlite3'
  gem 'mailcatcher'
  
  # Better error output
  gem 'better_errors'
  gem 'binding_of_caller'

  # Re-enable rails benchmarker/profiler
  gem 'ruby-prof'
  gem 'test-unit'

  # Get infos when not using proper eager loading
  gem 'bullet'

  # Hide assets requests in log
  gem 'quiet_assets'
  
  # Deploy with Capistrano
  gem 'capistrano', '2.13.5'
  gem 'capistrano-ext'
  #gem 'common_deploy', require: false, path: '../../common_deploy' # pending foodcoops/foodsoft#34,  git: 'git://github.com/fsmanuel/common_deploy.git'
  # Avoid having content-length warnings
  gem 'thin'
end
