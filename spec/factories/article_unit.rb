require 'factory_bot'

FactoryBot.define do
  factory :article_unit do
    sequence(:unit) { |n| Faker::Lorem.characters(number: rand(2..12)) + " ##{n}" }
  end
end
