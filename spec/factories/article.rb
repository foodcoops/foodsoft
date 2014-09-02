require 'factory_girl'

FactoryGirl.define do

  factory :article do
    sequence(:name) { |n| Faker::Lorem.words(rand(2..4)).join(' ') + " ##{n}" }
    unit { Faker::Unit.unit }
    price { rand(2600) / 100 }
    tax { [6, 21].sample }
    deposit { rand(10) < 8 ? 0 : [0.0, 0.80, 1.20, 12.00].sample }
    unit_quantity { rand(5) < 3 ? 1 : rand(1..20) }
    supplier { create :supplier }
    article_category { create :article_category }
  end

  factory :article_category do
    sequence(:name) { |n| Faker::Lorem.characters(rand(2..12)) + " ##{n}" }
  end

end
