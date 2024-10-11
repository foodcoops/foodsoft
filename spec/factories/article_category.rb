require 'factory_bot'

FactoryBot.define do
  factory :article_category do
    sequence(:name) { |n| Faker::Lorem.characters(number: rand(2..12)) + " ##{n}" }
  end
end
