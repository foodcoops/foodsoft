ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def login(nick='admin', pass='secret')
    open_session do |session|
      session.post '/f/login', nick: nick, password: pass
    end
  end

  def logout
    open_session do |session|
      session.post '/f/logout'
    end
  end
end
