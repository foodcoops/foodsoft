require 'factory_bot'

FactoryBot.define do
  factory :article_unit_ratio do
    unit { 'XPP' }
    sort { 1 }
    quantity { 1 }
    article_version
  end
end
