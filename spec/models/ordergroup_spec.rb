require './db/seeds/seed_helper.rb'
require_relative '../spec_helper'

def create_order(starts) # should be extracted to a helper file
    og = user.ordergroup

    SupplierCategory.create!(:id => 1, :name => "Other", :financial_transaction_class_id => ftc1.id)
    Supplier.create!([{ :id => 1, :name => "Beautiful bakery", :supplier_category_id => 1, :address => "Smallstreet 1, Cookilage", :phone => "0123456789", :email => "info@bbakery.test", :min_order_quantity => "100" },])
    ArticleCategory.create!(:id => 5, :name => "Bread & Bakery")
    Article.create!(:name => "Brown whole", :supplier_id => 1, :article_category_id => 5, :unit => "pc", :note => "organic", :availability => true, :manufacturer => "The Baker", :origin => "NL", :price => 0.22E1, :tax => 6.0, :deposit => 0.0, :unit_quantity => 1)

    order = seed_order(supplier_id: 1, starts: starts, ends: starts + 5.days, created_by_user_id: user.id, updated_by_user_id: user.id)

    go = og.group_orders.create!(order: order, updated_by_user_id: 1)
    goa = go.group_order_articles.find_or_create_by!(order_article: order.order_articles.first)
end

describe Ordergroup do
  let(:ftc1) { create :financial_transaction_class }
  let(:ftc2) { create :financial_transaction_class }
  let(:ftt1) { create :financial_transaction_type, financial_transaction_class: ftc1 }
  let(:ftt2) { create :financial_transaction_type, financial_transaction_class: ftc2 }
  let(:ftt3) { create :financial_transaction_type, financial_transaction_class: ftc2 }
  let(:user) { create :user, groups: [create(:ordergroup)] }
  
  it 'shows no active ordergroups when all orders are older than 3 months' do
    create_order(4.months.ago)
    expect(Ordergroup.active).to be_empty
  end

  it 'shows active ordergroups when there are recent orders' do
    create_order(2.days.ago)    
    expect(Ordergroup.active).not_to be_empty
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
