require 'spec_helper'

RSpec.describe OrdersController do
  let(:admin) { create(:user, groups: [create(:workgroup, role_orders: true)]) }
  let(:ordergroup) { create(:ordergroup) }
  let(:supplier) { create(:supplier) }
  let(:article) { create(:article, supplier: supplier) }
  let(:order) { create(:order, supplier: supplier, article_ids: [article.id]) }

  before do
    FoodsoftInvoices.enable_extensions!
    login(admin)
    # Minimal SEPA ready configuration
    FoodsoftConfig[:name] = 'Spec Coop'
    FoodsoftConfig[:group_order_invoices] = {
      iban: 'DE02120300000000202051',
      bic: 'BYLADEM1001',
      creditor_identifier: 'DE98ZZZ09999999999',
      payment_method: 'SEPA'
    }
    FoodsoftConfig[:contact] ||= {}
    FoodsoftConfig[:contact][:tax_number] = '123456789'
  end

  describe 'GET #collective_direct_debit' do
    context 'when SEPA is not ready' do
      it 'redirects with alert' do
        FoodsoftConfig[:group_order_invoices] = {}

        get_with_defaults :collective_direct_debit, params: { id: order.id }, format: :html

        expect(response).to redirect_to(finance_order_index_path)
        expect(flash[:alert]).to eq(I18n.t('activerecord.attributes.group_order_invoice.links.sepa_not_ready'))
      end
    end

    context 'with invalid mode' do
      it 'redirects with alert' do
        get_with_defaults :collective_direct_debit, params: { id: order.id, mode: 'invalid' }, format: :html

        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to eq(I18n.t('orders.collective_direct_debit.alert', ordergroup_names: ''))
      end
    end

    context 'with mode all and eligible group orders' do
      let!(:group_order) { create(:group_order, order: order, ordergroup: ordergroup) }

      before do
        # Prepare SEPA eligibility on group (stub to avoid association loading issues)
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Ordergroup).to receive(:sepa_possible?).and_return(true)
        # rubocop:enable RSpec/AnyInstance
        order.update!(state: 'closed')
        create(:group_order_invoice, group_order: group_order)
      end

      it 'sends xml data and marks invoices as downloaded' do
        # Stub XML generator to have deterministic output
        xml_double = instance_double(OrderCollectiveDirectDebitXml, xml_string: '<xml>ok</xml>')
        allow(OrderCollectiveDirectDebitXml).to receive(:new).and_return(xml_double)

        get_with_defaults :collective_direct_debit, params: { id: order.id, mode: 'all' }, format: :xml

        expect(response.media_type).to eq('text/xml')
        expect(response.body).to eq('<xml>ok</xml>')
        expect(OrderCollectiveDirectDebitXml).to have_received(:new)
        expect(group_order.reload.group_order_invoice.sepa_downloaded).to be(true)
      end
    end
  end
end
