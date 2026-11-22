require 'factory_bot'

FactoryBot.define do
  # requires order
  factory :group_order do
    ordergroup { create(:user, groups: [FactoryBot.create(:ordergroup)]).ordergroup }
    updated_by { create(:user) }
    order
  end
end
