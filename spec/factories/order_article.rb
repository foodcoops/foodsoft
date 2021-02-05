require 'factory_bot'

FactoryBot.define do

  factory :order_article do
    order
    article
  end

end
