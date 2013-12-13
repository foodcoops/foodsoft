require 'factory_girl'

FactoryGirl.define do

  # requires order
  factory :group_order do
    ordergroup { create(:user_and_ordergroup).ordergroup }
  end

end
