# Foodsoft API


## Authentication

The API uses OAuth2 based on [Doorkeeper](https://github.com/doorkeeper-gem).
For a quick start for development, add `skip_authorization { true }` to
config/initializers/doorkeeper.rb, and obtain an access token:

```ruby
require 'oauth2'
c = OAuth2::Client.new('', '', site: 'http://localhost:3002/f/', authorize_url: 'oauth/authorize', token_url: 'oauth/token')
c.password.get_token('admin', 'secret').token
# => "1234567890abcdef1234567890abcdef1234567890abcdef123456790abcdef1"
```

Now use this token as value for the `access_token` when accessing the API, like
http://localhost:3002/f/api/v1/financial_transactions/1?access_token=12345...


## Endpoints

### /:scope/api/v1/financial_transactions

### /:scope/api/v1/orders

### /:scope/api/v1/article_categories

