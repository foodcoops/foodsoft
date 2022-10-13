require_relative '../spec_helper'

describe Ordergroup do
  let(:ftc1) { create :financial_transaction_class }
  let(:ftc2) { create :financial_transaction_class }
  let(:ftt1) { create :financial_transaction_type, financial_transaction_class: ftc1 }
  let(:ftt2) { create :financial_transaction_type, financial_transaction_class: ftc2 }
  let(:ftt3) { create :financial_transaction_type, financial_transaction_class: ftc2 }
  let(:user) { create :user, groups: [create(:ordergroup)] }

  it 'shows no active ordergroups when all orders are older than 3 months' do
    order = create :order, starts: 4.months.ago
    user.ordergroup.group_orders.create!(order: order)

    expect(Ordergroup.active).to be_empty
  end

  it 'shows active ordergroups when there are recent orders' do
    order = create :order, starts: 2.days.ago
    user.ordergroup.group_orders.create!(order: order)

    expect(Ordergroup.active).not_to be_empty
  end

  describe 'sort correctly' do
    it 'by name' do
      group_b = create :ordergroup, name: 'bbb'
      group_a = create :ordergroup, name: 'aaa'
      group_c = create :ordergroup, name: 'ccc'

      expect(Ordergroup.sort_by_param('name')).to eq([group_a, group_b, group_c])
    end

    it 'reverse by name' do
      group_b = create :ordergroup, name: 'bbb'
      group_a = create :ordergroup, name: 'aaa'
      group_c = create :ordergroup, name: 'ccc'

      expect(Ordergroup.sort_by_param('name_reverse')).to eq([group_c, group_b, group_a])
    end

    it 'by members_count' do
      users_b = [create(:user)]
      users_a = []
      users_c = [create(:user), create(:user), create(:user)]
      group_b = create :ordergroup, name: 'bbb', user_ids: users_b.map(&:id)
      group_a = create :ordergroup, name: 'aaa', user_ids: users_a.map(&:id)
      group_c = create :ordergroup, name: 'ccc', user_ids: users_c.map(&:id)

      expect(Ordergroup.sort_by_param('members_count')).to eq([group_a, group_b, group_c])
    end

    it 'reverse by members_count' do
      users_b = [create(:user)]
      users_a = []
      users_c = [create(:user), create(:user), create(:user)]
      group_b = create :ordergroup, name: 'bbb', user_ids: users_b.map(&:id)
      group_a = create :ordergroup, name: 'aaa', user_ids: users_a.map(&:id)
      group_c = create :ordergroup, name: 'ccc', user_ids: users_c.map(&:id)

      expect(Ordergroup.sort_by_param('members_count_reverse')).to eq([group_c, group_b, group_a])
    end

    it 'by last_user_activity' do
      user_b = create :user, last_activity: 3.days.ago
      user_a = create :user, last_activity: 5.days.ago
      user_c = create :user, last_activity: Time.now
      group_b = create :ordergroup, name: 'bbb', user_ids: [user_b.id]
      group_a = create :ordergroup, name: 'aaa', user_ids: [user_a.id]
      group_c = create :ordergroup, name: 'ccc', user_ids: [user_c.id]

      expect(Ordergroup.sort_by_param('last_user_activity')).to eq([group_a, group_b, group_c])
    end

    it 'reverse by last_user_activity' do
      user_b = create :user, last_activity: 3.days.ago
      user_a = create :user, last_activity: 5.days.ago
      user_c = create :user, last_activity: Time.now
      group_b = create :ordergroup, name: 'bbb', user_ids: [user_b.id]
      group_a = create :ordergroup, name: 'aaa', user_ids: [user_a.id]
      group_c = create :ordergroup, name: 'ccc', user_ids: [user_c.id]

      expect(Ordergroup.sort_by_param('last_user_activity_reverse')).to eq([group_c, group_b, group_a])
    end

    it 'by last_order' do
      group_b = create :ordergroup, name: 'bbb'
      group_a = create :ordergroup, name: 'aaa'
      group_c = create :ordergroup, name: 'ccc'
      group_b.group_orders.create! order: create(:order, starts: 6.days.ago)
      group_a.group_orders.create! order: create(:order, starts: 4.months.ago)
      group_c.group_orders.create! order: create(:order, starts: Time.now)

      expect(Ordergroup.sort_by_param('last_order')).to eq([group_a, group_b, group_c])
    end

    it 'reverse by last_order' do
      group_b = create :ordergroup, name: 'bbb'
      group_a = create :ordergroup, name: 'aaa'
      group_c = create :ordergroup, name: 'ccc'
      group_b.group_orders.create! order: create(:order, starts: 6.days.ago)
      group_a.group_orders.create! order: create(:order, starts: 4.months.ago)
      group_c.group_orders.create! order: create(:order, starts: Time.now)

      expect(Ordergroup.sort_by_param('last_order_reverse')).to eq([group_c, group_b, group_a])
    end
  end

  context 'with financial transactions' do
    before do
      og = user.ordergroup
      og.add_financial_transaction!(-1, '-1', user, ftt1)
      og.add_financial_transaction!(2, '2', user, ftt1)
      og.add_financial_transaction!(3, '3', user, ftt1)

      og.add_financial_transaction!(-10, '-10', user, ftt2)
      og.add_financial_transaction!(20, '20', user, ftt2)
      og.add_financial_transaction!(30, '30', user, ftt2)

      og.add_financial_transaction!(-100, '-100', user, ftt3)
      og.add_financial_transaction!(200, '200', user, ftt3)
      og.add_financial_transaction!(300, '300', user, ftt3)
    end

    it 'has correct account balance' do
      og = user.ordergroup
      expect(og.account_balance).to eq 444

      ftc1.reload
      ftc1.update!(ignore_for_account_balance: true)

      og.reload
      expect(og.account_balance).to eq 440

      ftt2.reload
      ftt2.update!(financial_transaction_class: ftc1)

      og.reload
      expect(og.account_balance).to eq 400
    end

    it 'has correct FinancialTransactionClass sums' do
      og = user.ordergroup
      result = Ordergroup.include_transaction_class_sum.where(id: og).first
      expect(result["sum_of_class_#{ftc1.id}"]).to eq 4
      expect(result["sum_of_class_#{ftc2.id}"]).to eq 440

      ftt2.reload
      ftt2.update!(financial_transaction_class: ftc1)

      result = Ordergroup.include_transaction_class_sum.where(id: og).first
      expect(result["sum_of_class_#{ftc1.id}"]).to eq 44
      expect(result["sum_of_class_#{ftc2.id}"]).to eq 400
    end
  end
end
