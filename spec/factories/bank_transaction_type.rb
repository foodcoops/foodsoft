require 'factory_bot'

FactoryBot.define do
  factory :bank_account do
    name { Faker::Bank.name }
    iban { Faker::Bank.iban }
  end

  factory :bank_transaction do
    date { Faker::Date.backward(days: 14) }
    text { Faker::Lorem.sentence }
  end
end
