require 'factory_bot'

FactoryBot.define do
  factory :financial_transaction do
    user
    ordergroup
    amount { rand(-99_999.00..99_999.00) }
    note { Faker::Lorem.sentence }

    # This builds a new type and class by default, while for normal financial
    # transactions we'd use the default. This, however, is the easiest way to
    # get the factory going. If you want equal types, specify it explicitly.
    financial_transaction_type

    trait :pending do
      amount { nil }
    end
  end
end
