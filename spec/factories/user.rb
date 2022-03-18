require 'factory_bot'

FactoryBot.define do
  factory :user do
    sequence(:nick) { |n| "user#{n}" }
    first_name { Faker::Name.first_name }
    email { Faker::Internet.email }
    password { new_random_password }

    factory :admin do
      sequence(:nick) { |n| "admin#{n}" }
      first_name { 'Administrator' }
      after :create do |user, evaluator|
        create :workgroup, role_admin: true, user_ids: [user.id]
      end
    end

    trait :ordergroup do
      after :create do |user, evaluator|
        create :ordergroup, user_ids: [user.id]
      end
    end

    [:ordergroup, :finance, :invoices, :article_meta, :suppliers, :pickups, :orders].each do |role|
      trait "role_#{role}".to_sym do
        after :create do |user, evaluator|
          create :workgroup, "role_#{role}" => true, user_ids: [user.id]
        end
      end
    end
  end

  factory :group do
    sequence(:name) { |n| "Group ##{n}" }

    factory :workgroup do
      type { 'Workgroup' }
    end

    factory :ordergroup, class: "Ordergroup" do
      type { 'Ordergroup' }
      sequence(:name) { |n| "Order group ##{n}" }
      # workaround to avoid needing to save the ordergroup
      #   avoids e.g. error after logging in related to applebar
      after :create do |group| Ordergroup.find(group.id).update_stats! end
    end
  end
end
