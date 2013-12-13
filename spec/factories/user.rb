require 'factory_girl'

FactoryGirl.define do

  factory :_user do
    sequence(:nick) { |n| "user#{n}"}
    first_name { Faker::Name.first_name }
    email { Faker::Internet.email }
    password { new_random_password }

    # The signup plugin requires an ordergroup for most actions.
    # (use _user to create a user that definitely has no ordergroup)
    factory :user do
      if defined? FoodsoftSignup
        after :create do |user, evaluator|
          create :ordergroup, user_ids: [user.id]
        end
      end
    end

    # user with administrator access
    factory :admin do
      sequence(:nick) { |n| "admin#{n}" }
      first_name 'Administrator'
      after :create do |user, evaluator|
        create :workgroup, role_admin: true, user_ids: [user.id]
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
      # workaround to avoid needing to save the ordergroup
      #   avoids e.g. error after logging in related to applebar
      after :create do |group| Ordergroup.find(group.id).update_stats! end
      # The signup plugin prohibits certain actions when the ordergroup is not approved.
      #   To make normal tests succeed, default to true. To test the approval feature,
      #   just pass `:approved => false` when creating a new user in the tests.
      approved { true } if defined? FoodsoftSignup
    end
  end

end
