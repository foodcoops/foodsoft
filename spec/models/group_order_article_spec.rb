require_relative '../spec_helper'

describe GroupOrderArticle do
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:order) { create(:order) }
  let(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }
  let(:goa) { create(:group_order_article, group_order: go, order_article: order.order_articles.first) }

  it 'has zero quantity by default' do
    expect(goa.quantity).to eq(0)
  end

  it 'has zero tolerance by default' do
    expect(goa.tolerance).to eq(0)
  end

  it 'has zero result by default' do
    expect(goa.result).to eq(0)
  end

  it 'has zero total price by default' do
    expect(goa.total_price).to eq(0)
  end

  describe do
    let(:article) { create(:article, supplier: order.supplier, unit_quantity: 1) }
    let(:oa) { order.order_articles.create(article_version: article.latest_article_version) }
    let(:goa) { create(:group_order_article, group_order: go, order_article: oa) }

    it 'can be ordered by piece' do
      goa.update_quantities(1, 0)
      expect(goa.quantity).to eq(1)
      expect(goa.tolerance).to eq(0)
    end

    it 'can be ordered in larger amounts' do
      quantity = rand(13..99)
      tolerance = rand(0..99)
      goa.update_quantities(quantity, tolerance)
      expect(goa.quantity).to eq(quantity)
      expect(goa.tolerance).to eq(tolerance)
    end

    it 'has a proper total price' do
      quantity = rand(1..99)
      goa.update_quantities(quantity, 0)
      expect(goa.total_price).to eq(quantity * goa.order_article.price.fc_price)
    end

    it 'can unorder a product' do
      goa.update_quantities(rand(1..99), rand(0..99))
      goa.update_quantities(0, 0)
      expect(GroupOrderArticle.exists?(goa.id)).to be false
    end

    it 'updates quantity and tolerance' do
      goa.update_quantities(2, 2)
      goa.update_quantities(1, 1)
      expect(goa.quantity).to eq(1)
      expect(goa.tolerance).to eq(1)
      goa.update_quantities(1, 2)
      expect(goa.tolerance).to eq(2)
    end
  end

  describe 'distribution strategy' do
    let(:article) { create(:article, supplier: order.supplier, unit_quantity: 1) }
    let(:oa) { order.order_articles.create(article_version: article.latest_article_version) }
    let(:goa) { create(:group_order_article, group_order: go, order_article: oa) }
    let!(:goaq) { create(:group_order_article_quantity, group_order_article: goa, quantity: 4, tolerance: 6) }

    it 'can calculate the result for the distribution strategy "first order first serve"' do
      res = goa.calculate_result(2)
      expect(res).to eq(quantity: 2, tolerance: 0, total: 2)
    end

    it 'can calculate the result for the distribution strategy "no automatic distribution"' do
      FoodsoftConfig[:distribution_strategy] = FoodsoftConfig::DistributionStrategy::NO_AUTOMATIC_DISTRIBUTION

      res = goa.calculate_result(2)
      expect(res).to eq(quantity: 4, tolerance: 0, total: 4)
    end

    it 'determines tolerance correctly' do
      res = goa.calculate_result(6)
      expect(res).to eq(quantity: 4, tolerance: 2, total: 6)
    end
  end
end
