require 'factory_bot'

FactoryBot.define do

  factory :group_order do
    order
    ordergroup { create(:user, groups: [FactoryBot.create(:ordergroup)]).ordergroup }
    updated_by { create :user }
  end

end
