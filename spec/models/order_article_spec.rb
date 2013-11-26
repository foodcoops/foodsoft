require 'spec_helper'

describe OrderArticle do
  let(:order) { FactoryGirl.create :order, article_count: 1 }
  let(:oa) { order.order_articles.first }

  it 'is not ordered by default' do
    expect(OrderArticle.ordered.count).to eq 0
  end

  [:units_to_order, :units_billed, :units_received].each do |units|

    it "is ordered when there are #{units.to_s.gsub '_', ' '}" do
      oa.update_attribute units, rand(1..99)
      expect(OrderArticle.ordered.count).to eq 1
    end

  end

  it 'knows how many items there are' do
    oa.units_to_order = rand(1..99)
    expect(oa.units).to eq oa.units_to_order 
    oa.units_billed = rand(1..99)
    expect(oa.units).to eq oa.units_billed
    oa.units_received = rand(1..99)
    expect(oa.units).to eq oa.units_received

    oa.units_billed = rand(1..99)
    expect(oa.units).to eq oa.units_received
    oa.units_to_order = rand(1..99)
    expect(oa.units).to eq oa.units_received
    oa.units_received = rand(1..99)
    expect(oa.units).to eq oa.units_received
  end

  describe 'redistribution' do
    let(:admin) { FactoryGirl.create :user, groups:[FactoryGirl.create(:workgroup, role_finance: true)] }
    let(:article) { FactoryGirl.create :article, unit_quantity: 3 }
    let(:order) { FactoryGirl.create :order, article_ids: [article.id] }
    let(:go1) { FactoryGirl.create :group_order, order: order }
    let(:go2) { FactoryGirl.create :group_order, order: order }
    let(:go3) { FactoryGirl.create :group_order, order: order }
    let(:goa1) { FactoryGirl.create :group_order_article, group_order: go1, order_article: oa }
    let(:goa2) { FactoryGirl.create :group_order_article, group_order: go2, order_article: oa }
    let(:goa3) { FactoryGirl.create :group_order_article, group_order: go3, order_article: oa }

    # set quantities of group_order_articles
    def set_quantities(q1, q2, q3)
      goa1.update_quantities(*q1)
      goa2.update_quantities(*q2)
      goa3.update_quantities(*q3)
      oa.update_results!
      order.finish!(admin)
      goa_reload
    end

    # reload all group_order_articles
    def goa_reload
      [goa1, goa2, goa3].map(&:reload)
    end

    it 'has expected units_to_order' do
      set_quantities [3,2], [1,3], [1,0]
      expect(oa.units*oa.article.unit_quantity).to eq 6
      expect([goa1, goa2, goa3].map(&:result)).to eq [4, 1, 1]
    end

    it 'does nothing when nothing has changed' do
      set_quantities [3,2], [1,3], [1,0]
      expect(oa.redistribute 6, [:tolerance, nil]).to eq [1, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result).map(&:to_i)).to eq [4, 1, 1]
    end

    it 'works when there is nothing to distribute' do
      set_quantities [3,2], [1,3], [1,0]
      expect(oa.redistribute 0, [:tolerance, nil]).to eq [0, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [0, 0, 0]
    end

    it 'works when quantity needs to be reduced' do
      set_quantities [3,2], [1,3], [1,0]
      expect(oa.redistribute 4, [:tolerance, nil]).to eq [0, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [3, 1, 0]
    end

    it 'works when quantity is increased within quantity' do
      set_quantities [3,0], [2,0], [2,0]
      expect([goa1, goa2, goa3].map(&:result)).to eq [3, 2, 1]
      expect(oa.redistribute 7, [:tolerance, nil]).to eq [0, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result).map(&:to_i)).to eq [3, 2, 2]
    end

    it 'works when there is just one for the first' do
      set_quantities [3,2], [1,3], [1,0]
      expect(oa.redistribute 1, [:tolerance, nil]).to eq [0, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [1, 0, 0]
    end

    it 'works when there is tolerance and left-over' do
      set_quantities [3,2], [1,1], [1,0]
      expect(oa.redistribute 10, [:tolerance, nil]).to eq [3, 2]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [5, 2, 1]
    end

    it 'works when redistributing without tolerance' do
      set_quantities [3,2], [1,3], [1,0]
      expect(oa.redistribute 8, [nil]).to eq [3]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [3, 1, 1]
    end

  end

end
