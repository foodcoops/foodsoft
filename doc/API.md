# Foodsoft API


## Endpoints

### /:scope/api/v1/financial_transactions

### /:scope/api/v1/orders

### /:scope/api/v1/article_categories


## Security

Uses the [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) gem,
which provides an OAuth2 provider.


### Authorization code flow

This is the recommended flow (certainly when building a web-app), where
members login with Foodsoft, then redirected to the app, which then obtains
an access token using the authorization code supplied at redirection.

Before you can obtain an access token, the client needs to obtain an id and secret.
(You can currently skip this for the password credentials flow.) This needs to be
done for each Foodsoft scope by an admin.

1. Click on the _Apps_ button at the right in Foodsoft's configuration screen.
2. Click on _New application_
3. Enter any _Name_ and put the website of your app in _Redirect URI_ and _Submit_.
4. Click on the new applications' name for the app id and secret.
5. To quickly test, logging into the app, press _Authorize_.

Not that the user doesn't need to confirm that he is giving the app access to his
Foodsoft account by default, since apps can only be created by admins. If you
want to change that, see disable `skip_authorization` in `config/initializers/doorkeeper.rb`.

[Read more](https://github.com/doorkeeper-gem/doorkeeper/wiki/authorization-flow).


### Password credentials flow

The API uses OAuth2 based on [Doorkeeper](https://github.com/doorkeeper-gem).
To obtain a token using a username/password directly, you can do this:

```ruby
require 'oauth2'
c = OAuth2::Client.new('', '', site: 'http://localhost:3002/f/', authorize_url: 'oauth/authorize', token_url: 'oauth/token')
c.password.get_token('admin', 'secret').token
# => "1234567890abcdef1234567890abcdef1234567890abcdef123456790abcdef1"
```

Now use this token as value for the `access_token` when accessing the API, like
http://localhost:3002/f/api/v1/financial_transactions/1?access_token=12345...

[Read more](https://github.com/doorkeeper-gem/doorkeeper/wiki/Client-Credentials-flow).

