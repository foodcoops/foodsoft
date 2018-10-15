require 'factory_bot'

FactoryBot.define do

  factory :order do
    starts { Time.now }
    supplier { create :supplier, article_count: (article_count.nil? ? true : article_count) }
    article_ids { supplier.articles.map(&:id) unless supplier.nil? }

    transient do
      article_count true
    end

    # for an order from stock
    factory :stock_order do
      supplier_id 0
      after :create do |order, evaluator|
        article_count = evaluator.article_count
        article_count = rand(1..99) if article_count == true
        create_list :stock_article, article_count
      end
    end

    # In the order's after_save callback order articles are created, so
    # until the order is saved, these articles do not yet exist.
    after :create do |order|
      order.reload
    end
  end

end
