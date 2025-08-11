require 'spec_helper'

describe MultiOrder do
  let(:admin) { create(:user, groups: [create(:workgroup, role_finance: true), create(:ordergroup, name: 'AdminOrders')]) }
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:order) { create(:order) }
  let(:another_order) { create(:order) }

  before do
    FoodsoftInvoices.enable_extensions!
  end

  context 'when orders are open' do
    let!(:order_group_order) { create(:group_order, ordergroup: user.ordergroup, order: order) }
    let!(:another_order_group_order) { create(:group_order, ordergroup: user.ordergroup, order: another_order) }

    before do
      order.update!(state: 'open')
      another_order.update!(state: 'open')
      FoodsoftConfig[:contact][:tax_number] = 123_457_8
    end

    it 'cannot be created' do
      expect { create(:multi_order, orders: [order]) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'cannot be created with existing invoices' do
      order.update!(state: 'closed')
      another_order.update!(state: 'closed')
      order_group_order.update!(group_order_invoice: create(:group_order_invoice))
      another_order_group_order.update!(group_order_invoice: create(:group_order_invoice))
      expect { create(:multi_order, orders: [order, another_order]) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'when orders are closed' do
    let(:yet_another_order) { create(:order) }

    before do
      create(:group_order, ordergroup: user.ordergroup, order: order)
      create(:group_order, ordergroup: user.ordergroup, order: another_order)

      order.update!(state: 'closed')
      another_order.update!(state: 'closed')
      yet_another_order.update!(state: 'closed')
    end

    it 'is valid for one order' do
      expect(create(:multi_order, orders: [order])).to be_valid
    end

    it 'is valid for two orders' do
      expect(create(:multi_order, orders: [order, another_order])).to be_valid
    end
  end
end
