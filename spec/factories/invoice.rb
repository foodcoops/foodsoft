require 'factory_bot'

FactoryBot.define do

  factory :invoice do
    supplier
    number { rand(1..99999) }
    amount { rand(0.1..26.0).round(2) }

    after :create do |invoice|
      invoice.supplier.reload
    end
  end

end
