require 'spec_helper'

describe OrderArticle do
  let(:order) { create(:order, article_count: 1) }
  let(:oa) { order.order_articles.first }

  it 'is not ordered by default' do
    expect(OrderArticle.ordered.count).to eq 0
  end

  %i[units_to_order units_billed units_received].each do |units|
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

  it 'calculates the difference of received articles to ordered articles' do
    oa.units_received = 10
    oa.units_to_order = 2
    expect(oa.difference_received_ordered).to eq(8)

    oa.units_received = 2
    oa.units_to_order = 10
    expect(oa.difference_received_ordered).to eq(-8)

    oa.units_received = nil
    oa.units_to_order = 10
    expect(oa.difference_received_ordered).to eq(-10)
  end

  describe 'redistribution' do
    let(:admin) { create(:user, groups: [create(:workgroup, role_finance: true)]) }
    let(:article) { create(:article, unit_quantity: 3) }
    let(:order) { create(:order, article_ids: [article.id]) }
    let(:go1) { create(:group_order, order: order) }
    let(:go2) { create(:group_order, order: order) }
    let(:go3) { create(:group_order, order: order) }
    let(:goa1) { create(:group_order_article, group_order: go1, order_article: oa) }
    let(:goa2) { create(:group_order_article, group_order: go2, order_article: oa) }
    let(:goa3) { create(:group_order_article, group_order: go3, order_article: oa) }

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
      set_quantities [3, 2], [1, 3], [1, 0]
      expect(oa.units * oa.article_version.unit_quantity).to eq 6
      expect([goa1, goa2, goa3].map(&:result)).to eq [4, 1, 1]
    end

    it 'does nothing when nothing has changed' do
      set_quantities [3, 2], [1, 3], [1, 0]
      expect(oa.redistribute(6, [:tolerance, nil])).to eq [1, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result).map(&:to_i)).to eq [4, 1, 1]
    end

    it 'works when there is nothing to distribute' do
      set_quantities [3, 2], [1, 3], [1, 0]
      expect(oa.redistribute(0, [:tolerance, nil])).to eq [0, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [0, 0, 0]
    end

    it 'works when quantity needs to be reduced' do
      set_quantities [3, 2], [1, 3], [1, 0]
      expect(oa.redistribute(4, [:tolerance, nil])).to eq [0, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [3, 1, 0]
    end

    it 'works when quantity is increased within quantity' do
      set_quantities [3, 0], [2, 0], [2, 0]
      expect([goa1, goa2, goa3].map(&:result)).to eq [3, 2, 1]
      expect(oa.redistribute(7, [:tolerance, nil])).to eq [0, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result).map(&:to_i)).to eq [3, 2, 2]
    end

    it 'works when there is just one for the first' do
      set_quantities [3, 2], [1, 3], [1, 0]
      expect(oa.redistribute(1, [:tolerance, nil])).to eq [0, 0]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [1, 0, 0]
    end

    it 'works when there is tolerance and left-over' do
      set_quantities [3, 2], [1, 1], [1, 0]
      expect(oa.redistribute(10, [:tolerance, nil])).to eq [3, 2]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [5, 2, 1]
    end

    it 'works when redistributing without tolerance' do
      set_quantities [3, 2], [1, 3], [1, 0]
      expect(oa.redistribute(8, [nil])).to eq [3]
      goa_reload
      expect([goa1, goa2, goa3].map(&:result)).to eq [3, 1, 1]
    end
  end

  describe 'boxfill' do
    before { FoodsoftConfig[:use_boxfill] = true }

    let(:article) { create(:article, unit_quantity: 6) }
    let(:order) { create(:order, article_ids: [article.id], starts: 1.week.ago) }
    let(:oa) { order.order_articles.first }
    let(:go) { create(:group_order, order: order) }
    let(:goa) { create(:group_order_article, group_order: go, order_article: oa) }

    shared_examples 'boxfill' do |success, q|
      # initial situation
      before do
        goa.update_quantities(*q.keys[0])
        oa.update_results!
        oa.reload
      end

      # check starting condition
      it '(before)' do
        expect([oa.quantity, oa.tolerance, oa.missing_units]).to eq q.keys[1]
      end

      # actual test
      it(success ? 'succeeds' : 'fails') do
        order.update(boxfill: boxfill_from)

        r = proc {
          goa.update_quantities(*q.values[0])
          oa.update_results!
        }
        if success
          r.call
        else
          expect(r).to raise_error(ActiveRecord::RecordNotSaved)
        end

        oa.reload
        expect([oa.quantity, oa.tolerance, oa.missing_units]).to eq q.values[1]
      end
    end

    context 'before the date' do
      let(:boxfill_from) { 1.hour.from_now }

      context 'decreasing the missing units' do
        include_examples 'boxfill', true, [6, 0] => [5, 0], [6, 0, 0] => [5, 0, 1]
      end

      context 'decreasing the tolerance' do
        include_examples 'boxfill', true, [1, 2] => [1, 1], [1, 2, 3] => [1, 1, 4]
      end
    end

    context 'after the date' do
      let(:boxfill_from) { 1.second.ago }

      context 'changing nothing in particular' do
        include_examples 'boxfill', true, [4, 1] => [4, 1], [4, 1, 1] => [4, 1, 1]
      end

      context 'increasing missing units' do
        include_examples 'boxfill', false, [3, 0] => [2, 0], [3, 0, 3] => [3, 0, 3]
      end

      context 'increasing tolerance' do
        include_examples 'boxfill', true, [2, 1] => [2, 2], [2, 1, 3] => [2, 2, 2]
      end

      context 'decreasing quantity to fix missing units' do
        include_examples 'boxfill', true, [7, 0] => [6, 0], [7, 0, 5] => [6, 0, 0]
      end

      context 'decreasing quantity keeping missing units equal' do
        include_examples 'boxfill', false, [7, 0] => [1, 0], [7, 0, 5] => [7, 0, 5]
      end

      context 'moving tolerance to quantity' do
        include_examples 'boxfill', true, [4, 2] => [6, 0], [4, 2, 0] => [6, 0, 0]
      end
      # @todo enable test when tolerance doesn't count in missing_units
      # context 'decreasing tolerance' do
      #   include_examples "boxfill", false, [0,2]=>[0,0], [0,2,0]=>[0,2,0]
      # end
    end
  end

  describe 'minimum order quantity' do
    let(:order) { create(:order, article_ids: [article.id], starts: 1.week.ago) }
    let(:oa) { order.order_articles.first }
    let(:go) { create(:group_order, order: order) }
    let(:goa) { create(:group_order_article, group_order: go, order_article: oa) }

    shared_context 'minimum order quantity' do |quantity|
      before do
        goa.update_quantities(quantity[:quantity], quantity[:tolerance])
        oa.update_results!
        oa.reload
      end

      it 'is calculated correctly' do
        expect(oa.units_to_order).to eq quantity[:expected_units_to_order]
      end
    end

    context 'without unit_quantity' do
      let(:article) { create(:article, minimum_order_quantity: 10) }

      context 'doesn\'t order anything, if the minimum order quantity hasn\'t been reached' do
        include_examples 'minimum order quantity', { quantity: 4, tolerance: 0, expected_units_to_order: 0 }
      end

      context 'orders the minimum order quantity, if tolerance allows for it' do
        include_examples 'minimum order quantity', { quantity: 9, tolerance: 1, expected_units_to_order: 10 }
      end

      context 'orders the desired amount, if minimum order quantity has been surpassed' do
        include_examples 'minimum order quantity', { quantity: 12, tolerance: 1, expected_units_to_order: 12 }
      end
    end

    context 'with unit_quantity' do
      let(:article) { create(:article, minimum_order_quantity: 2, unit_quantity: 5) }

      context 'doesn\'t order anything if the minimum order quantity hasn\'t been reached' do
        include_examples 'minimum order quantity', { quantity: 4, tolerance: 0, expected_units_to_order: 0 }
      end

      context 'orders the minimum order quantity if tolerance allows for it' do
        include_examples 'minimum order quantity', { quantity: 9, tolerance: 1, expected_units_to_order: 2 }
      end

      context 'orders a lower amount, even if minimum order quantity has been surpassed, but unit_quantity demands it' do
        include_examples 'minimum order quantity', { quantity: 12, tolerance: 1, expected_units_to_order: 2 }
      end

      context 'orders the exact amount, if minimum order quantity has been surpassed and unit_quantity allows for it' do
        include_examples 'minimum order quantity', { quantity: 14, tolerance: 1, expected_units_to_order: 3 }
      end
    end
  end
end
