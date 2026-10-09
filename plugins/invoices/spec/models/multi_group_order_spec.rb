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

  context 'when combined group orders have financial transactions' do
    let(:ordergroup) { user.ordergroup }

    def setup_orders(type1, type2)
      order1 = create(:order)
      order2 = create(:order)
      go1 = create(:group_order, ordergroup: ordergroup, order: order1)
      go2 = create(:group_order, ordergroup: ordergroup, order: order2)
      create(:financial_transaction, group_order: go1, ordergroup: ordergroup, financial_transaction_type: type1)
      create(:financial_transaction, group_order: go2, ordergroup: ordergroup, financial_transaction_type: type2)
      order1.update!(state: 'closed')
      order2.update!(state: 'closed')
      [order1, order2]
    end

    it 'is not created when the financial transaction types differ' do
      orders = setup_orders(create(:financial_transaction_type), create(:financial_transaction_type))
      expect { create(:multi_order, orders: orders) }.to raise_error(ActiveRecord::RecordInvalid, /consistent|einheitlich/)
      expect(described_class.count).to eq(0)
    end

    it 'is created when the financial transaction types are the same' do
      type = create(:financial_transaction_type)
      orders = setup_orders(type, type)
      expect { create(:multi_order, orders: orders) }.to change(described_class, :count).by(1)
    end
  end
end
