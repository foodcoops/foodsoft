require 'factory_bot'

FactoryBot.define do
  factory :supplier do
    name { Faker::Company.name.truncate(30) }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.street_address }

    transient do
      article_count { 0 }
    end

    before :create do |supplier, evaluator|
      next if supplier.class == SharedSupplier
      next if supplier.supplier_category_id?

      supplier.supplier_category = create :supplier_category
    end

    after :create do |supplier, evaluator|
      article_count = evaluator.article_count
      article_count = rand(1..99) if article_count == true
      create_list :article, article_count, supplier: supplier
    end

    factory :shared_supplier, class: 'SharedSupplier'
  end

  factory :supplier_category do
    sequence(:name) { |n| Faker::Lorem.characters(number: rand(2..12)) + " ##{n}" }
    financial_transaction_class
  end
end
