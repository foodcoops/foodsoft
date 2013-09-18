require 'spec_helper'

describe Article do
  let(:supplier) { FactoryGirl.create :supplier }
  let(:article) { FactoryGirl.create :article, supplier: supplier }

  it 'has a unique name+unit' do
    article2 = FactoryGirl.build :article, supplier: supplier, name: article.name, unit: article.unit
    expect(article2).to be_invalid
  end

  it 'computes the gross price correctly' do
    article.deposit = 0
    article.tax = 12
    expect(article.gross_price).to eq((article.price * 1.12).round(2))
    article.deposit = 1.20
    expect(article.gross_price).to eq(((article.price + 1.20) * 1.12).round(2))
  end

  it 'gross price >= net price' do
    expect(article.gross_price).to be >= article.price
  end

  it 'fc-price >= gross price' do
    if article.gross_price > 0
      expect(article.fc_price).to be > article.gross_price
    else
      expect(article.fc_price).to be >= article.gross_price
    end
  end

  it 'knows when it is deleted' do
    expect(supplier.deleted?).to be_false
    supplier.mark_as_deleted
    expect(supplier.deleted?).to be_true
  end

  it 'keeps a price history' do
    expect(article.article_prices.all.map(&:price)).to eq([article.price])
    oldprice = article.price
    sleep 1 # so that the new price really has a later creation time
    article.price += 1
    article.save!
    expect(article.article_prices.all.map(&:price)).to eq([article.price, oldprice])
  end

end
