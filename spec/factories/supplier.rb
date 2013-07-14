require 'factory_girl'

FactoryGirl.define do

  factory :supplier do
    name { Faker::Company.name }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.street_address }

    ignore do
      article_count 0
    end

    after :create do |supplier, evaluator|
      FactoryGirl.create_list :article, evaluator.article_count, supplier: supplier
    end
  end

end
