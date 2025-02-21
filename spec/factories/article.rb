require 'factory_bot'

FactoryBot.define do
  factory :_article do
    factory :article do
      supplier

      transient do
        article_version_count { 1 }
        order_number { nil }
        unit_quantity { nil }
        unit { nil }
        minimum_order_quantity { nil }
        supplier_order_unit { 'XPK' }
        group_order_unit { 'XPK' }
        billing_unit { 'XPK' }
        price_unit { 'XPK' }
        article_unit_ratio_count { 1 }
      end

      after(:create) do |article, evaluator|
        create_list(:article_version, evaluator.article_version_count,
                    article: article,
                    order_number: evaluator.order_number,
                    unit_quantity: evaluator.unit_quantity,
                    unit: evaluator.unit,
                    minimum_order_quantity: evaluator.minimum_order_quantity,
                    supplier_order_unit: evaluator.supplier_order_unit,
                    group_order_unit: evaluator.group_order_unit,
                    billing_unit: evaluator.billing_unit,
                    price_unit: evaluator.price_unit,
                    article_unit_ratio_count: evaluator.article_unit_ratio_count)

        article.reload
      end
    end

    factory :stock_article, class: 'StockArticle' do
      supplier

      transient do
        stock_article_version_count { 1 }
        price { 1 }
      end

      after(:create) do |stock_article, evaluator|
        create_list(:article_version, evaluator.stock_article_version_count, article: stock_article, price: evaluator.price)

        stock_article.reload
      end
    end
  end
end
