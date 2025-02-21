require 'factory_bot'
FactoryBot.define do
  factory :article_version do
    sequence(:name) { |n| Faker::Lorem.words(number: rand(2..4)).join(' ') + " ##{n}" }
    supplier_order_unit { 'XPK' }
    group_order_unit { 'XPK' }
    billing_unit { 'XPK' }
    price { rand(0.1..26.0).round(2) }
    price_unit { 'XPK' }
    tax { [6, 21].sample }
    deposit { rand(10) < 8 ? 0 : [0.0, 0.80, 1.20, 12.00].sample }
    article_category
    article

    transient do
      article_unit_ratio_count { 1 }
      unit_quantity { 1 }
      unit { nil }
    end

    after(:create) do |article_version, evaluator|
      unless evaluator.unit_quantity.nil?
        article_version.group_order_unit = 'XPP'
        article_version.save
      end
      unless evaluator.unit.nil?
        article_version.supplier_order_unit = nil
        article_version.unit = evaluator.unit
        article_version.save
      end
      build_list(:article_unit_ratio, evaluator.article_unit_ratio_count,
                 article_version: article_version) do |record, i|
        if !evaluator.unit_quantity.nil? && i == 0
          record.quantity = evaluator.unit_quantity
          record.unit = 'XPP'
        end
        record.sort = i + 1
        record.save
        record.reload
      end
    end
  end
end
