require 'factory_bot'

FactoryBot.define do
  factory :order_article do
    order { create :order }
    article { create :article }
  end
end
