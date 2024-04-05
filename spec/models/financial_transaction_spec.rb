require_relative '../spec_helper'

describe FinancialTransaction do
  let!(:ordergroup) { create(:ordergroup) }
  let!(:ft) { create(:financial_transaction, ordergroup: ordergroup, amount: 20) }

  it 'updates the amount of the ordergroup balance' do
    expect(ordergroup.account_balance).to eq(20)
    create(:financial_transaction, ordergroup: ordergroup, amount: 10)
    expect(ordergroup.account_balance).to eq(30)
  end

  it 'can be reverted' do
    ft.revert!(ft.user)
    expect(ft).to be_hidden
    expect(ordergroup.financial_transactions.count).to eq 2
    expect(ordergroup.financial_transactions.last.amount).to eq(-20)
    expect(ordergroup.financial_transactions.last.reverts).to eq ft
    expect(ordergroup.account_balance).to eq 0
  end

  context 'with a pending transaction' do
    let!(:ft) { create(:financial_transaction, :pending, ordergroup: ordergroup) }

    it 'fails on revert' do
      puts ft.inspect
      expect { ft.revert!(ft.user) }.to raise_error(RuntimeError, 'Pending Transaction cannot be reverted')
    end
  end
end
