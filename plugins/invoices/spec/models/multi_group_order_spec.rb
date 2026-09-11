require 'spec_helper'

describe MultiGroupOrder do
  let(:admin) { create(:user, groups: [create(:workgroup, role_finance: true), create(:ordergroup, name: 'AdminOrders')]) }
  let(:user) { create(:user, groups: [create(:ordergroup)]) }

  before do
    FoodsoftInvoices.enable_extensions!
  end

  context 'when orders are not closed' do
    it 'is not generated without valid multi_order' do
      order1 = create(:order)
      order2 = create(:order)
      create(:group_order, ordergroup: user.ordergroup, order: order1)
      create(:group_order, ordergroup: user.ordergroup, order: order2)
      expect { create(:multi_order, orders: [order1, order2]) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(described_class.count).to eq(0)
    end
  end

  context 'when orders are closed' do
    it 'is created by MultiOrder' do
      order1 = create(:order)
      order2 = create(:order)
      create(:group_order, ordergroup: user.ordergroup, order: order1)
      create(:group_order, ordergroup: user.ordergroup, order: order2)
      order1.update!(state: 'closed')
      order2.update!(state: 'closed')
      create(:multi_order, orders: [order1, order2])
      expect(described_class.count).to eq(1)
    end
  end
end
