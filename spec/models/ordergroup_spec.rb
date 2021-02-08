require_relative '../spec_helper'

describe Ordergroup do
  let(:ftc1) { create :financial_transaction_class }
  let(:ftc2) { create :financial_transaction_class }
  let(:ftt1) { create :financial_transaction_type, financial_transaction_class: ftc1 }
  let(:ftt2) { create :financial_transaction_type, financial_transaction_class: ftc2 }
  let(:ftt3) { create :financial_transaction_type, financial_transaction_class: ftc2 }
  let(:user) { create :user, groups:[create(:ordergroup)] }

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
      ftc1.update_attributes!(ignore_for_account_balance: true)

      og.reload
      expect(og.account_balance).to eq 440

      ftt2.reload
      ftt2.update_attributes!(financial_transaction_class: ftc1)

      og.reload
      expect(og.account_balance).to eq 400
    end

    it 'has correct FinancialTransactionClass sums' do
      og = user.ordergroup
      result = Ordergroup.include_transaction_class_sum.where(id: og).first
      expect(result["sum_of_class_#{ftc1.id}"]).to eq 4
      expect(result["sum_of_class_#{ftc2.id}"]).to eq 440

      ftt2.reload
      ftt2.update_attributes!(financial_transaction_class: ftc1)

      result = Ordergroup.include_transaction_class_sum.where(id: og).first
      expect(result["sum_of_class_#{ftc1.id}"]).to eq 44
      expect(result["sum_of_class_#{ftc2.id}"]).to eq 400
    end
  end
end
