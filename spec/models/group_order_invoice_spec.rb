require_relative '../spec_helper'

describe GroupOrderInvoice do
  let(:user) { create :user, groups: [create(:ordergroup)] }
  let(:supplier) { create :supplier }
  let(:article) { create :article, supplier: supplier }
  let(:order) { create :order }
  let(:group_order) { create :group_order, order: order, ordergroup: user.ordergroup }

  describe 'erroneous group order invoice' do
    let(:goi) { create :group_order_invoice, group_order_id: group_order.id }
    it 'does not create group order invoice if tax_number not set' do
      expect { goi }.to raise_error(ActiveRecord::RecordInvalid, /.*/)
    end
  end

  describe 'valid group order invoice' do
    before do
      FoodsoftConfig[:contact][:tax_number] = 123_457_8
    end

    invoice_number1 = Time.now.strftime("%Y%m%d") + '0001'
    invoice_number2 = Time.now.strftime("%Y%m%d") + '0002'

    let(:user2) { create :user, groups: [create(:ordergroup)] }

    let(:goi1) { create :group_order_invoice, group_order_id: group_order.id }
    let(:goi2) { create :group_order_invoice, group_order_id: group_order.id }

    let(:group_order2) { create :group_order, order: order, ordergroup: user2.ordergroup }

    let(:goi3) { create :group_order_invoice, group_order_id: group_order2.id }
    let(:goi4) { create :group_order_invoice, group_order_id: group_order2.id, invoice_number: invoice_number1 }

    it 'creates group order invoice if tax_number is set' do
      expect(goi1).to be_valid
    end

    it 'sets invoice_number according to date' do
      number = Time.now.strftime("%Y%m%d") + '0001'
      expect(goi1.invoice_number).to eq(number.to_i)
    end

    it 'fails to create if group_order_id is used multiple times for creation' do
      expect(goi1.group_order.id).to eq(group_order.id)
      expect { goi2 }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'creates two different group order invoice with different invoice_numbers' do
      expect(goi1.invoice_number).to eq(invoice_number1.to_i)
      expect(goi3.invoice_number).to eq(invoice_number2.to_i)
    end

    it 'fails to create two different group order invoice with same invoice_numbers' do
      goi1
      expect { goi4 }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
