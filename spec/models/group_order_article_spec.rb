require 'spec_helper'

describe GroupOrderArticle do
  let(:user) { FactoryGirl.create :user, groups: [FactoryGirl.create(:ordergroup)] }
  let(:supplier) { FactoryGirl.create :supplier, article_count: true }
  let(:order) { FactoryGirl.create(:order, supplier: supplier, article_ids: supplier.articles.map(&:id)).reload }
  let(:go) { FactoryGirl.create :group_order, order: order, ordergroup: user.ordergroup }
  let(:goa) { FactoryGirl.create :group_order_article, group_order: go, order_article: order.order_articles.first }

  it 'has zero quantity by default'    do goa.quantity.should == 0 end
  it 'has zero tolerance by default'   do goa.tolerance.should == 0 end
  it 'has zero result by default'      do goa.result.should == 0 end
  it 'is not ordered by default'       do GroupOrderArticle.ordered.where(:id => goa.id).exists?.should be_false end
  it 'has zero total price by default' do goa.total_price.should == 0 end

  describe do
    let(:article) { FactoryGirl.create :article, supplier: supplier, unit_quantity: 1 }
    let(:goa) { article; FactoryGirl.create :group_order_article, group_order: go, order_article: order.order_articles.find_by_article_id(article.id) }

    it 'can be ordered by piece' do
      goa.update_quantities(1, 0)
      goa.quantity.should == 1
      goa.tolerance == 0
    end

    it 'can be ordered in larger amounts' do
      quantity, tolerance = rand(13..100), rand(0..100)
      goa.update_quantities(quantity, tolerance)
      goa.quantity.should == quantity
      goa.tolerance.should == tolerance
    end

    it 'has a proper total price' do
      quantity = rand(1..100)
      goa.update_quantities(quantity, 0)
      goa.total_price.should == quantity * goa.order_article.price.fc_price
    end

    it 'can unorder a product' do
      goa.update_quantities(rand(1..100), rand(0..100))
      goa.update_quantities(0, 0)
      goa.quantity.should == 0
      goa.tolerance.should == 0
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
      goaq.quantity.should == startq
      goaq.tolerance.should == startt
    end

  end

end
