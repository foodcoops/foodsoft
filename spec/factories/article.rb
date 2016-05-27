require 'factory_bot'

FactoryBot.define do

  factory :_article do
    sequence(:name) { |n| Faker::Lorem.words(rand(2..4)).join(' ') + " ##{n}" }
    unit { Faker::Unit.unit }
    price { rand(0.1..26.0).round(2) }
    tax { [6, 21].sample }
    deposit { rand(10) < 8 ? 0 : [0.0, 0.80, 1.20, 12.00].sample }
    unit_quantity { rand(5) < 3 ? 1 : rand(1..20) }

    factory :article do
      supplier
      article_category
    end

    factory :shared_article, class: SharedArticle do
      order_number { Faker::Lorem.characters(rand(1..12)) }
      supplier factory: :shared_supplier
    end

    factory :stock_article, class: StockArticle do
      supplier_id 0
      quantity { rand(20) + 1 }
      article_category
    end
  end

  factory :article_category do
    sequence(:name) { |n| Faker::Lorem.characters(rand(2..12)) + " ##{n}" }
  end

end
