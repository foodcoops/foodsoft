require 'spec_helper'

RSpec.describe Finance::BalancingController do
  let(:admin) { create(:user, groups: [create(:workgroup, role_finance: true)]) }
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:supplier) { create(:supplier) }
  let(:article) { create(:article, supplier: supplier) }

  before do
    FoodsoftInvoices.enable_extensions!
    login(admin)
  end

  describe 'GET #index' do
    it 'combines MultiOrders and finished non-multi orders' do
      # One finished non-multi order
      solo_order = create(:order, supplier: supplier, article_ids: [article.id])
      create(:group_order, order: solo_order, ordergroup: user.ordergroup)
      solo_order.update!(state: 'closed')

      # Two closed orders grouped into a multi order
      o1 = create(:order, supplier: supplier, article_ids: [article.id])
      o2 = create(:order, supplier: supplier, article_ids: [article.id])
      create(:group_order, order: o1, ordergroup: user.ordergroup)
      create(:group_order, order: o2, ordergroup: user.ordergroup)
      o1.update!(state: 'closed')
      o2.update!(state: 'closed')
      multi = create(:multi_order, orders: [o1, o2])

      captured = nil

      allow(Kaminari).to receive(:paginate_array).and_wrap_original do |m, arr|
        captured = arr
        m.call(arr)
      end

      get_with_defaults :index

      expect(Kaminari).to have_received(:paginate_array)
      expect(captured).to include(multi)
      expect(captured).to include(solo_order)
    end
  end
end
