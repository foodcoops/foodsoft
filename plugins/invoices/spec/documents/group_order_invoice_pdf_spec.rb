require 'spec_helper'

describe GroupOrderInvoicePdf do
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:supplier) { create(:supplier, name: 'Test Supplier') }
  let(:article) { create(:article, supplier: supplier) }
  let(:order) { create(:order, supplier: supplier, article_ids: [article.id]) }
  let(:group_order) { create(:group_order, order: order, ordergroup: user.ordergroup) }
  let(:invoice_number) { 2_025_072_900_001 }
  let(:invoice_date) { Date.new(2025, 7, 29) }

  before do
    FoodsoftConfig[:contact] = {
      street: 'Test Street 123',
      zip_code: '12345',
      city: 'Test City',
      email: 'test@example.com',
      phone: '123-456-7890',
      tax_number: '123456789'
    }
  end

  describe '#filename' do
    it 'returns the correct filename' do
      pdf = described_class.new(
        ordergroup: user.ordergroup,
        invoice_number: invoice_number
      )

      expected_filename = "#{user.ordergroup.name}_" +
                          I18n.t('documents.group_order_invoice_pdf.filename', number: invoice_number) +
                          '.pdf'

      expect(pdf.filename).to eq(expected_filename)
    end
  end

  describe '#title' do
    it 'returns the correct title' do
      pdf = described_class.new(
        supplier: supplier.name
      )

      expected_title = I18n.t('documents.group_order_invoice_pdf.title', supplier: supplier.name)

      expect(pdf.title).to eq(expected_title)
    end
  end

  describe '#body' do
    context 'with VAT exempt configuration' do
      before do
        FoodsoftConfig[:group_order_invoices] = { vat_exempt: true }
      end

      it 'calls body_for_vat_exempt method' do
        pdf = described_class.new(
          ordergroup: user.ordergroup,
          supplier: supplier.name,
          invoice_number: invoice_number,
          invoice_date: invoice_date,
          group_order_ids: [group_order.id],
          tax_number: FoodsoftConfig[:contact][:tax_number],
          payment_method: 'Cash'
        )

        allow(pdf).to receive(:body_for_vat_exempt)
        pdf.body
        expect(pdf).to have_received(:body_for_vat_exempt)
      end
    end

    context 'with VAT included configuration' do
      before do
        FoodsoftConfig[:group_order_invoices] = { vat_exempt: false }
      end

      it 'calls body_with_vat method' do
        pdf = described_class.new(
          ordergroup: user.ordergroup,
          supplier: supplier.name,
          invoice_number: invoice_number,
          invoice_date: invoice_date,
          group_order_ids: [group_order.id],
          tax_number: FoodsoftConfig[:contact][:tax_number],
          payment_method: 'Cash'
        )

        allow(pdf).to receive(:body_with_vat)
        pdf.body
        expect(pdf).to have_received(:body_with_vat)
      end
    end
  end
end
