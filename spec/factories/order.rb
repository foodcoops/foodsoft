require 'factory_girl'

FactoryGirl.define do

  factory :order do
    starts { Time.now }
    supplier { create :supplier, article_count: (article_count.nil? ? true : article_count) }
    article_ids { supplier.articles.map(&:id) unless supplier.nil? }

    ignore do
      article_count true
    end

    # for an order from stock; need to add articles
    factory :stock_order do
      supplier_id 0
      # article_ids needs to be supplied
    end

    # In the order's after_save callback order articles are created, so
    # until the order is saved, these articles do not yet exist.
    after :create do |order|
      order.reload
    end
  end

end
