require_relative '../spec_helper'

describe BankTransaction do
  let(:bank_account) { create :bank_account }
  let(:ordergroup) { create :ordergroup }
  let(:supplier) { create :supplier, iban: Faker::Bank.iban }
  let!(:user) { create :user, groups: [ordergroup] }
  let!(:ftt_a) { create :financial_transaction_type, name_short: 'A' }
  let!(:ftt_b) { create :financial_transaction_type, name_short: 'B' }

  describe 'supplier' do
    let!(:invoice1) { create :invoice, supplier: supplier, number: '11', amount: 10 }
    let!(:invoice2) { create :invoice, supplier: supplier, number: '22', amount: 20 }
    let!(:invoice3) { create :invoice, supplier: supplier, number: '33', amount: 30 }
    let!(:invoice4) { create :invoice, supplier: supplier, number: '44', amount: 40 }
    let!(:invoice5) { create :invoice, supplier: supplier, number: '55', amount: 50 }

    let!(:bank_transaction1) { create :bank_transaction, bank_account: bank_account, iban: supplier.iban, reference: '11', amount: 10 }
    let!(:bank_transaction2) { create :bank_transaction, bank_account: bank_account, iban: supplier.iban, reference: '22', amount: -20 }
    let!(:bank_transaction3) { create :bank_transaction, bank_account: bank_account, iban: supplier.iban, reference: '33,44', amount: -70 }
    let!(:bank_transaction4) { create :bank_transaction, bank_account: bank_account, iban: supplier.iban, text: '55', amount: -50 }

    it 'ignores invoices with invalid amount' do
      expect(bank_transaction1.assign_to_invoice).to be false
    end

    it 'can assign single invoice' do
      expect(bank_transaction2.assign_to_invoice).to be true
      invoice2.reload
      expect(invoice2.paid_on).to eq bank_transaction2.date
      expect(invoice2.financial_link).to eq bank_transaction2.financial_link
    end

    it 'can assign multiple invoice' do
      expect(bank_transaction3.assign_to_invoice).to be true
      [invoice3, invoice4].each(&:reload)
      expect(invoice3.paid_on).to eq bank_transaction3.date
      expect(invoice4.paid_on).to eq bank_transaction3.date
      expect(invoice3.financial_link).to eq bank_transaction3.financial_link
      expect(invoice4.financial_link).to eq bank_transaction3.financial_link
    end

    it 'can assign single invoice with number in text' do
      expect(bank_transaction4.assign_to_invoice).to be true
      invoice5.reload
      expect(invoice5.paid_on).to eq bank_transaction4.date
      expect(invoice5.financial_link).to eq bank_transaction4.financial_link
    end

  end

  describe 'ordergroup' do
    let!(:bank_transaction1) { create :bank_transaction, bank_account: bank_account, reference: "invalid", amount: 10 }
    let!(:bank_transaction2) { create :bank_transaction, bank_account: bank_account, reference: "FS99A10", amount: 10 }
    let!(:bank_transaction3) { create :bank_transaction, bank_account: bank_account, reference: "FS#{ordergroup.id}.99A10", amount: 10 }
    let!(:bank_transaction4) { create :bank_transaction, bank_account: bank_account, reference: "FS#{ordergroup.id}A10", amount: 99 }
    let!(:bank_transaction5) { create :bank_transaction, bank_account: bank_account, reference: "FS#{ordergroup.id}A10", amount: 10 }
    let!(:bank_transaction6) { create :bank_transaction, bank_account: bank_account, reference: "FS#{ordergroup.id}A10B20", amount: 30 }
    let!(:bank_transaction7) { create :bank_transaction, bank_account: bank_account, reference: "FS#{ordergroup.id}.#{user.id}A10", amount: 10 }
    let!(:bank_transaction8) { create :bank_transaction, bank_account: bank_account, reference: "FS#{ordergroup.id}X10", amount: 10 }

    it 'ignores transaction with invalid reference' do
      expect(bank_transaction1.assign_to_ordergroup).to be nil
    end

    it 'ignores transaction with invalid ordergroup' do
      expect(bank_transaction2.assign_to_ordergroup).to be false
    end

    it 'ignores transaction with invalid user' do
      expect(bank_transaction3.assign_to_ordergroup).to be false
    end

    it 'ignores transaction with invalid sum' do
      expect(bank_transaction4.assign_to_ordergroup).to be false
    end

    it 'add transaction with one part' do
      expect(bank_transaction5.assign_to_ordergroup).to be true
      ft_a = user.ordergroup.financial_transactions.where(financial_transaction_type: ftt_a).first
      expect(ft_a.amount).to eq 10
      expect(ft_a.financial_link).to eq bank_transaction5.financial_link
    end

    it 'add transaction with multiple parts' do
      expect(bank_transaction6.assign_to_ordergroup).to be true
      ft_a = user.ordergroup.financial_transactions.where(financial_transaction_type: ftt_a).first
      ft_b = user.ordergroup.financial_transactions.where(financial_transaction_type: ftt_b).first
      expect(ft_a.amount).to eq 10
      expect(ft_a.financial_link).to eq bank_transaction6.financial_link
      expect(ft_b.amount).to eq 20
      expect(ft_b.financial_link).to eq bank_transaction6.financial_link
    end

    it 'add transaction with one part and user' do
      expect(bank_transaction7.assign_to_ordergroup).to be true
      ft_a = user.ordergroup.financial_transactions.where(financial_transaction_type: ftt_a).first
      expect(ft_a.amount).to eq 10
      expect(ft_a.financial_link).to eq bank_transaction7.financial_link
    end

    it 'ignores transaction with invalid short name' do
      expect(bank_transaction8.assign_to_ordergroup).to be false
    end

  end

end
