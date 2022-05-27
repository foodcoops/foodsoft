# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

# https://gist.github.com/ebeigarts/5450422
map ENV.fetch('RAILS_RELATIVE_URL_ROOT', '/') do
  run Foodsoft::Application
end
