require 'factory_bot'

FactoryBot.define do
  factory :invite do
    user { create :user }
    group { create :group }
    email { Faker::Internet.email }

    factory :expired_invite do
      after :create do |invite|
        invite.update_column(:expires_at, Time.now.yesterday)
      end
    end
  end
end
