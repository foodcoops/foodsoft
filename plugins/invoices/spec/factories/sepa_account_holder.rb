require 'factory_bot'

FactoryBot.define do
  factory :sepa_account_holder do
    group
    user
    iban { 'DE02120300000000202051' }
    bic { 'BYLADEM1001' }
    mandate_id { "MDT-#{SecureRandom.hex(4)}" }
    mandate_date_of_signature { Time.zone.today }
  end
end
