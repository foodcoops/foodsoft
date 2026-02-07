require_relative '../spec_helper'

describe Article do
  let(:supplier) { create(:supplier) }
  let(:article) { create(:article, supplier: supplier) }
  let(:user) { create(:user, groups: [create(:ordergroup)]) }

  it 'has a unique name' do
    article_version_copy = article.latest_article_version.dup
    article2 = FactoryBot.build(:article, supplier_id: article.supplier_id, latest_article_version: article_version_copy)
    article2.latest_article_version.article = article2
    expect(article2.latest_article_version).to be_invalid
    expect(article2.latest_article_version.errors.first.type).to eq :taken
    expect(article2.latest_article_version.errors.first.attribute).to eq :name
  end

  it 'can be deleted' do
    expect(article).not_to be_deleted
    article.mark_as_deleted
    expect(article).to be_deleted
  end

  it 'computes changed article attributes' do
    article_version_copy = article.latest_article_version.dup
    article_version_copy.name = 'banana'
    article2 = FactoryBot.build(:article, supplier_id: article.supplier_id, latest_article_version: article_version_copy)
    article2.latest_article_version.article = article2
    unequal_attributes = article.unequal_attributes(article2)
    expect(unequal_attributes[:name]).to eq 'banana'
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

  [[nil, 1],
   [0,   1],
   [5,   1.05],
   [42,  1.42],
   [100, 2]].each do |price_markup, percent|
    it "computes the fc price with price_markup #{price_markup} correctly" do
      FoodsoftConfig.config['price_markup'] = price_markup
      expect(article.fc_price).to eq((article.gross_price * percent).round(2))
    end
  end
  it 'knows when it is deleted' do
    expect(supplier.deleted?).to be false
    supplier.mark_as_deleted
    expect(supplier.deleted?).to be true
  end

  it "doesn't keep an article history for articles not referenced by closed orders" do
    expect(article.article_versions.map(&:price)).to eq([article.price])
    oldprice = article.price
    sleep 1 # so that the new price really has a later creation time
    article.price += 1
    article.save!
    expect(article.article_versions.reload.map(&:price)).to eq([article.price])
  end

  it 'keeps an article history for articles referenced by closed orders' do
    order = create(:order, created_by: user, starts: Date.yesterday, ends: 1.hour.ago, end_action: :auto_close)
    order.close!(user)
    article = order.order_articles.first.article_version.article

    expect(article.article_versions.map(&:price)).to eq([article.price])
    oldprice = article.price

    sleep 1 # so that the new price really has a later creation time
    article.price += 1
    article.save!
    expect(article.article_versions.reload.map(&:price)).to eq([article.price, oldprice])
  end

  it 'is not in an open order by default' do
    expect(article.in_open_order).to be_nil
  end

  it 'is knows its open order' do
    order = create(:order, supplier: supplier, article_ids: [article.id])
    expect(article.in_open_order).to eq(order)
  end
end
