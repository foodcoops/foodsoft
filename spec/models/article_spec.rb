require 'spec_helper'

describe Article do
  let(:supplier) { FactoryGirl.create :supplier }
  let(:article) { FactoryGirl.create :article, supplier: supplier }

  it 'has a unique name' do
    article2 = FactoryGirl.build :article, supplier: supplier, name: article.name
    article2.should_not be_valid
  end

  it 'computes the gross price correctly' do
    article.deposit = 0
    article.tax = 12
    article.gross_price.should == (article.price * 1.12).round(2)
    article.deposit = 1.20
    article.gross_price.should == ((article.price + 1.20) * 1.12).round(2)
  end

  it 'gross price >= net price' do
    article.gross_price.should >= article.price
  end

  it 'fc-price > gross price' do
    article.fc_price.should > article.gross_price
  end

  it 'knows when it is deleted' do
    supplier.deleted?.should be_false
    supplier.mark_as_deleted
    supplier.deleted?.should be_true
  end

  it 'keeps a price history' do
    article.article_prices.count.should == 1
    oldprice = article.price
    article.price += 1
    article.save!
    article.article_prices.count.should == 2
    article.article_prices[0].price.should == article.price
    article.article_prices[-1].price.should == oldprice
  end

end
