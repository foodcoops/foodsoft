# frozen_string_literal: true

module SpecTestHelper
  def login(user)
    user = User.find_by_nick(user.nick)
    session[:user_id] = user.id
    session[:scope] = FoodsoftConfig[:default_scope] # Save scope in session to not allow switching between foodcoops with one account
    session[:locale] = user.locale
  end

  def current_user
    User.find(session[:user_id])
  end

  def get_with_defaults(action, **args)
    get(action, **default_request_args(**args))
  end

  def post_with_defaults(action, **args)
    post(action, **default_request_args(**args))
  end

  def delete_with_defaults(action, **args)
    delete(action, **default_request_args(**args))
  end

  def default_request_args(params: {}, xhr: false, format: nil)
    params['foodcoop'] = FoodsoftConfig[:default_scope]
    { params: params, xhr: xhr, format: format }
  end
end

RSpec.configure do |config|
  config.include SpecTestHelper, type: :controller
end
