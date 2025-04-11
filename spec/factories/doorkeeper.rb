require 'factory_bot'
require 'doorkeeper'

FactoryBot.define do
  factory :oauth2_application, class: 'Doorkeeper::Application' do
    name { Faker::App.name }
    redirect_uri { 'https://example.com:1234/app' }
  end

  factory :oauth2_access_token, class: 'Doorkeeper::AccessToken' do
    application factory: :oauth2_application
  end
end
