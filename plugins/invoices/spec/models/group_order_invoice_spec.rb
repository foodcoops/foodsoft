require 'spec_helper'

describe GroupOrderInvoice do
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:supplier) { create(:supplier) }
  let(:article) { create(:article, supplier: supplier) }
  let(:order) { create(:order, supplier: supplier, article_ids: [article.id]) }
  let(:group_order) { create(:group_order, order: order, ordergroup: user.ordergroup) }

  describe 'erroneous group order invoice' do
    let(:invoice) { create(:group_order_invoice, group_order_id: group_order.id) }

    it 'does not create group order invoice if tax_number not set' do
      expect { invoice }.to raise_error(ActiveRecord::RecordInvalid, /.*/)
    end
  end

  describe 'valid group order invoice' do
    before do
      FoodsoftConfig[:contact][:tax_number] = 123_457_8
    end

    invoice_number1 = Time.now.strftime('%Y%m%d') + '0001'
    invoice_number2 = Time.now.strftime('%Y%m%d') + '0002'

    let(:user2) { create(:user, groups: [create(:ordergroup)]) }

    let(:invoice) { create(:group_order_invoice, group_order_id: group_order.id) }
    let(:invoice_duplicate) { create(:group_order_invoice, group_order_id: group_order.id) }

    let(:another_order_group_order) { create(:group_order, order: order, ordergroup: user2.ordergroup) }

    let(:another_invoice) { create(:group_order_invoice, group_order_id: another_order_group_order.id) }
    let(:invoice_with_duplicate_number) { create(:group_order_invoice, group_order_id: another_order_group_order.id, invoice_number: invoice_number1) }

    it 'creates group order invoice if tax_number is set' do
      expect(invoice).to be_valid
    end

    it 'sets invoice_number according to date' do
      number = Time.now.strftime('%Y%m%d') + '0001'
      expect(invoice.invoice_number).to eq(number.to_i)
    end

    it 'fails to create if group_order_id is used multiple times for creation' do
      expect(invoice.group_order.id).to eq(group_order.id)
      expect { invoice_duplicate }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'creates two different group order invoice with different invoice_numbers' do
      expect(invoice.invoice_number).to eq(invoice_number1.to_i)
      expect(another_invoice.invoice_number).to eq(invoice_number2.to_i)
    end

    it 'fails to create two different group order invoice with same invoice_numbers' do
      invoice
      expect { invoice_with_duplicate_number }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
