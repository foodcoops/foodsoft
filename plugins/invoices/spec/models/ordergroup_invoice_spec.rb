require 'spec_helper'

RSpec.describe OrdergroupInvoice do
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:ordergroup) { user.ordergroup }
  let(:supplier) { create(:supplier, name: 'Spec Supplier') }
  let(:article) { create(:article, supplier: supplier) }
  let(:first_order) { create(:order, supplier: supplier, article_ids: [article.id]) }
  let(:second_order) { create(:order, supplier: supplier, article_ids: [article.id]) }

  before do
    FoodsoftInvoices.enable_extensions!
    FoodsoftConfig[:contact] ||= {}
    FoodsoftConfig[:contact][:tax_number] = 12_345_678
    FoodsoftConfig[:name] = 'Spec Foodcoop'
  end

  def build_multi_group_order
    create(:group_order, ordergroup: ordergroup, order: first_order)
    create(:group_order, ordergroup: ordergroup, order: second_order)

    first_order.update!(state: 'closed')
    second_order.update!(state: 'closed')

    multi_order = create(:multi_order, orders: [first_order, second_order])
    multi_order.multi_group_orders.first
  end

  context 'with initialization and defaults' do
    it 'sets invoice_date, invoice_number and payment_method from config' do
      FoodsoftConfig[:ordergroup_invoices] = { payment_method: 'Bank transfer' }
      mgo = build_multi_group_order

      invoice = described_class.create!(multi_group_order: mgo)

      expect(invoice.invoice_date).to be_present
      expect(invoice.invoice_number).to be_present
      expect(invoice.payment_method).to eq('Bank transfer')
    end

    it 'fails validation when tax number is missing' do
      FoodsoftConfig[:contact][:tax_number] = nil
      mgo = build_multi_group_order

      expect { described_class.create!(multi_group_order: mgo) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#load_data_for_invoice' do
    it 'returns expected invoice data' do
      FoodsoftConfig[:ordergroup_invoices] = { payment_method: 'Direct debit' }
      mgo = build_multi_group_order
      invoice = described_class.create!(multi_group_order: mgo)

      data = invoice.load_data_for_invoice

      expect(data[:pickup]).to eq(first_order.pickup)
      expect(data[:supplier]).to eq('Spec Foodcoop')
      expect(data[:ordergroup]).to eq(ordergroup)
      expect(data[:group_order_ids]).to match_array(mgo.group_orders.pluck(:id))
      expect(data[:invoice_number]).to eq(invoice.invoice_number)
      expect(data[:invoice_date]).to eq(invoice.invoice_date)
      expect(data[:tax_number]).to eq(12_345_678)
      expect(data[:payment_method]).to eq('Direct debit')
      expect(data[:order_articles]).to be_a(Hash)
    end
  end

  describe 'InvoiceCommon behaviour' do
    it 'returns a translated name including the invoice number' do
      mgo = build_multi_group_order
      invoice = described_class.create!(multi_group_order: mgo)
      expected_prefix = I18n.t('activerecord.attributes.ordergroup_invoice.name')

      expect(invoice.name).to eq("#{expected_prefix}_#{invoice.invoice_number}")
    end

    it 'marks and unmarks SEPA downloaded' do
      mgo = build_multi_group_order
      invoice = described_class.create!(multi_group_order: mgo)

      invoice.mark_sepa_downloaded
      expect(invoice.reload.sepa_downloaded).to be(true)

      invoice.unmark_sepa_downloaded
      expect(invoice.reload.sepa_downloaded).to be(false)
    end
  end
end
