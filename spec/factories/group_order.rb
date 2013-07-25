require 'factory_girl'

FactoryGirl.define do

  # requires order
  factory :group_order do
    ordergroup { FactoryGirl.create(:user, groups: [FactoryGirl.create(:ordergroup)]).ordergroup }
  end

end
