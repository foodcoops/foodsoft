require 'factory_girl'

FactoryGirl.define do

  factory :financial_transaction_class do
    sequence(:name) { |n| Faker::Lorem.characters(rand(2..12)) + " ##{n}" }
  end

  factory :financial_transaction_type do
    sequence(:name) { |n| Faker::Lorem.words(rand(2..4)).join(' ') + " ##{n}" }
  end

end
