require 'factory_bot'

FactoryBot.define do
  factory :_article do
    unit { Faker::Unit.unit }
    price { rand(0.1..26.0).round(2) }
    tax { [6, 21].sample }
    deposit { rand(10) < 8 ? 0 : [0.0, 0.80, 1.20, 12.00].sample }
    unit_quantity { rand(5) < 3 ? 1 : rand(1..20) }

    factory :article do
      sequence(:name) { |n| Faker::Lorem.words(number: rand(2..4)).join(' ') + " ##{n}" }
      supplier
      article_category
    end

    factory :shared_article, class: 'SharedArticle' do
      sequence(:name) { |n| Faker::Lorem.words(number: rand(2..4)).join(' ') + " s##{n}" }
      order_number { Faker::Lorem.characters(number: rand(1..12)) }
      shared_supplier
    end

    factory :stock_article, class: 'StockArticle' do
      sequence(:name) { |n| Faker::Lorem.words(number: rand(2..4)).join(' ') + " ##{n}" }
      unit_quantity { 1 }
      supplier
      article_category
    end
  end

  factory :article_category do
    sequence(:name) { |n| Faker::Lorem.characters(number: rand(2..12)) + " ##{n}" }
  end
end
