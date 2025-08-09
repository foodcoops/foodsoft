require 'factory_bot'

FactoryBot.define do
  factory :multi_order do
    after(:build) do |multi_order, evaluator|
      # Assign orders before validation so custom validations can see them
      multi_order.orders = evaluator.orders
    end

    after(:create) do |multi_order, _evaluator|
      # Persist the relationship by updating the orders (if needed)
      multi_order.orders.each do |order|
        order.update!(multi_order: multi_order)
      end
    end
  end
end
