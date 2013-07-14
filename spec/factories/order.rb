require 'factory_girl'

FactoryGirl.define do

  # requires articles from single supplier, or supplier (with all its articles)
  factory :order do
    starts { Time.now }

    factory :stock_order do
      supplier_id 0
    end
  end

end
