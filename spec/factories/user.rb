require 'factory_girl'

FactoryGirl.define do

  factory :user do
    sequence(:nick) { |n| "user#{n}"}
    first_name { Faker::Name.first_name }
    email { Faker::Internet.email }
    password { new_random_password }

    factory :admin do
      sequence(:nick) { |n| "admin#{n}" }
      first_name 'Administrator'
      after :create do |user, evaluator|
        FactoryGirl.create :workgroup, role_admin: true, user_ids: [user.id]
      end
    end
  end

  factory :group do
    sequence(:name) {|n| "Group ##{n}"}

    factory :workgroup do
      type ''
    end

    factory :ordergroup do
      type 'Ordergroup'
      sequence(:name) {|n| "Order group ##{n}"}
    end
  end

end
