require_relative '../spec_helper'

describe GroupOrder do
  let(:order) { create :order }
  let(:go)  { create :group_order, order: order }

  # the following two tests are currently disabled - https://github.com/foodcoops/foodsoft/issues/158

  #it 'needs an order' do
  #  expect(build :group_order, order: nil).to be_invalid
  #end

  #it 'needs an ordergroup' do
  #  expect(build :group_order, ordergroup: nil).to be_invalid
  #end

  it 'has zero price initially' do
    expect(go.price).to eq(0)
  end

  describe 'with ordergroup price markup' do
    let(:admin) { create :admin }
    let(:oa) { order.order_articles.first }
    let(:go2) { create :group_order, order: order }
    let(:goa) { create :group_order_article, group_order: go, order_article: oa }
    let(:goa2) { create :group_order_article, group_order: go2, order_article: oa }

    before do
      FoodsoftConfig.config[:price_markup] = 'default'
      FoodsoftConfig.config[:price_markup_list] = {'low' => {'markup' => 2.5}, 'default' => {'markup' => 5}, 'high' => {'markup' => 20}}
      Ordergroup.find(go.ordergroup).update_attribute :price_markup_key, 'high'
      Ordergroup.find(go2.ordergroup).update_attribute :price_markup_key, 'low'
    end

    it 'can mix different markups' do
      uq = oa.price.unit_quantity
      goa.update_quantities uq, 0
      goa2.update_quantities uq, 0
      go.update_price!; go2.update_price!; oa.update_results!
      go.reload; go2.reload; oa.reload
      expect(go.price).to be > go2.price
      expect(oa.group_orders_sum[:price]).to eq uq*oa.price.fc_price(go.ordergroup) + uq*oa.price.fc_price(go2.ordergroup)
    end

  end

end
