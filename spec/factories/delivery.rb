require 'factory_bot'

FactoryBot.define do
  factory :delivery do
    supplier { create :supplier }
    date { Time.now }
  end
end
