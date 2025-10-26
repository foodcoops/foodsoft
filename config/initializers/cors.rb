# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    # this restricts Foodsoft scopes to certain characters - let's discuss it when it becomes an actual problem
    resource %r{\A/[-a-zA-Z0-9_]+/api/v[0-9]+/}, headers: :any, methods: :any
  end
end
