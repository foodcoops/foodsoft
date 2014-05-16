require_relative '../spec_helper'

describe GroupOrderArticle do
  let(:order) { create(:order) }
  let(:oa) { order.order_articles.first }
  let(:go) { create :group_order, order: order }
  let(:goa) { create :group_order_article, group_order: go, order_article: oa }

  it 'has zero quantity by default'    do expect(goa.quantity).to eq(0) end
  it 'has zero tolerance by default'   do expect(goa.tolerance).to eq(0) end
  it 'has zero result by default'      do expect(goa.result).to eq(0) end
  it 'has zero total price by default' do expect(goa.total_price).to eq(0) end

  describe do
    let(:article) { create :article, supplier: order.supplier, unit_quantity: 1 }
    let(:oa) { order.order_articles.create article: article }
    let(:goa) { create :group_order_article, group_order: go, order_article: oa }

    it 'can be ordered by piece' do
      goa.update_quantities(1, 0)
      expect(goa.quantity).to eq(1)
      expect(goa.tolerance).to eq(0)
    end

    it 'can be ordered in larger amounts' do
      quantity, tolerance = rand(13..99), rand(0..99)
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
      expect(GroupOrderArticle.exists?(goa.id)).to be_false
    end


    describe 'with global price markup' do
      before do
        FoodsoftConfig.config[:price_markup] = 5.0
        FoodsoftConfig.config[:price_markup_list] = nil
      end

      it 'has equal markup' do
        goa.update_quantities 1, 0
        expect(goa.total_price).to eq oa.price.fc_price
      end
    end

    describe 'with ordergroup price markup' do
      before do
        FoodsoftConfig.config[:price_markup] = 'default'
        FoodsoftConfig.config[:price_markup_list] = {'low' => {'markup' => 2.5}, 'default' => {'markup' => 5}, 'high' => {'markup' => 20}}
      end

      it 'has default markup by default' do
        goa.update_quantities 1, 0
        expect(goa.total_price).to eq oa.price.fc_price
      end

      it 'has high markup when set' do
        go.ordergroup.price_markup_key = 'high'
        goa.update_quantities 1, 0
        expect(goa.total_price).to be > oa.price.fc_price
        expect(goa.total_price).to eq oa.price.fc_price(go.ordergroup)
      end
    end
  end

end
