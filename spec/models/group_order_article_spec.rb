require 'spec_helper'

describe GroupOrderArticle do
  let(:user) { FactoryGirl.create :user, groups: [FactoryGirl.create(:ordergroup)] }
  let(:supplier) { FactoryGirl.create :supplier, article_count: true }
  let(:order) { FactoryGirl.create(:order, supplier: supplier, article_ids: supplier.articles.map(&:id)).reload }
  let(:go) { FactoryGirl.create :group_order, order: order, ordergroup: user.ordergroup }
  let(:goa) { FactoryGirl.create :group_order_article, group_order: go, order_article: order.order_articles.first }

  it 'has zero quantity by default'    do expect(goa.quantity).to eq(0) end
  it 'has zero tolerance by default'   do expect(goa.tolerance).to eq(0) end
  it 'has zero result by default'      do expect(goa.result).to eq(0) end
  it 'is not ordered by default'       do expect(GroupOrderArticle.ordered.where(:id => goa.id).exists?).to be_false end
  it 'has zero total price by default' do expect(goa.total_price).to eq(0) end

  describe do
    let(:article) { FactoryGirl.create :article, supplier: supplier, unit_quantity: 1 }
    let(:goa) { article; FactoryGirl.create :group_order_article, group_order: go, order_article: order.order_articles.find_by_article_id(article.id) }

    it 'can be ordered by piece' do
      goa.update_quantities(1, 0)
      expect(goa.quantity).to eq(1)
      expect(goa.tolerance).to eq(0)
    end

    it 'can be ordered in larger amounts' do
      quantity, tolerance = rand(13..100), rand(0..100)
      goa.update_quantities(quantity, tolerance)
      expect(goa.quantity).to eq(quantity)
      expect(goa.tolerance).to eq(tolerance)
    end

    it 'has a proper total price' do
      quantity = rand(1..100)
      goa.update_quantities(quantity, 0)
      expect(goa.total_price).to eq(quantity * goa.order_article.price.fc_price)
    end

    it 'can unorder a product' do
      goa.update_quantities(rand(1..100), rand(0..100))
      goa.update_quantities(0, 0)
      expect(goa.quantity).to eq(0)
      expect(goa.tolerance).to eq(0)
    end

    it 'keeps track of article quantities' do
      startq = startt = nil
      for i in 0..6 do
        goa.group_order_article_quantities.count == i
        quantity, tolerance = rand(1..100), rand(0..100)
        goa.update_quantities(quantity, tolerance)
        startq.nil? and startq = quantity
        startt.nil? and startt = tolerance
      end
      goaq = goa.group_order_article_quantities.last
      expect(goaq.quantity).to eq(startq)
      expect(goaq.tolerance).to eq(startt)
    end

  end

end
