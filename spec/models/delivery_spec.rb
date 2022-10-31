require_relative '../spec_helper'

describe Delivery do
  let(:delivery) { create :delivery }
  let(:stock_article) { create :stock_article, price: 3 }

  it 'creates new stock_changes' do
    delivery.new_stock_changes = ([
      {
        quantity: 1,
        stock_article: stock_article
      },
      {
        quantity: 2,
        stock_article: stock_article
      }
    ])

    expect(delivery.stock_changes.last[:stock_article_id]).to be stock_article.id
    expect(delivery.includes_article?(stock_article)).to be true
    expect(delivery.sum(:net)).to eq 9
  end
end
