require 'spec_helper'

RSpec.describe MultiOrdersController do
  let(:sepa_og) { create(:ordergroup_with_sepa) }
  let(:admin) { create(:user, groups: [create(:workgroup, role_finance: true)]) }
  let(:user)  { create(:user, groups: [sepa_og]) }
  let(:supplier) { create(:supplier) }
  let(:article)  { create(:article, supplier: supplier) }

  before do
    FoodsoftInvoices.enable_extensions!
    login(admin)
    FoodsoftConfig[:contact] ||= {}
    FoodsoftConfig[:contact][:tax_number] = '123456789'
  end

  describe 'POST #create' do
    it 'creates a MultiOrder for closed orders (JS)' do
      o1 = create(:order, supplier: supplier, article_ids: [article.id])
      o2 = create(:order, supplier: supplier, article_ids: [article.id])
      create(:group_order, order: o1, ordergroup: user.ordergroup)
      create(:group_order, order: o2, ordergroup: user.ordergroup)
      o1.update!(state: 'closed')
      o2.update!(state: 'closed')

      expect do
        post_with_defaults :create, params: { order_ids_for_multi_order: [o1.id, o2.id] }, xhr: true, format: :js
      end.to change(MultiOrder, :count).by(1)

      expect(response).to be_successful
      expect(flash[:notice]).to be_present
    end

    it 'rejects multi-multi creation with alert (JS)' do
      post_with_defaults :create, params: { multi_order_ids_for_multi_multi_order: [1, 2] }, xhr: true, format: :js

      expect(response).to be_successful
      expect(flash[:alert]).to eq(I18n.t('multi_orders.create.no_multi_multi'))
    end

    it 'rejects when one order is not closed (JS)' do
      o1 = create(:order, supplier: supplier, article_ids: [article.id])
      o2 = create(:order, supplier: supplier, article_ids: [article.id])
      create(:group_order, order: o1, ordergroup: user.ordergroup)
      create(:group_order, order: o2, ordergroup: user.ordergroup)
      o1.update!(state: 'closed')
      o2.update!(state: 'open')

      post_with_defaults :create, params: { order_ids_for_multi_order: [o1.id, o2.id] }, xhr: true, format: :js

      expect(response).to be_successful
      expect(flash[:alert]).to eq(I18n.t('multi_orders.create.invalid_orders'))
    end

    it 'rejects when orders already have invoices (JS)' do
      o1 = create(:order, supplier: supplier, article_ids: [article.id])
      o2 = create(:order, supplier: supplier, article_ids: [article.id])
      go1 = create(:group_order, order: o1, ordergroup: user.ordergroup)
      go2 = create(:group_order, order: o2, ordergroup: user.ordergroup)
      o1.update!(state: 'closed')
      o2.update!(state: 'closed')
      create(:group_order_invoice, group_order: go1)
      create(:group_order_invoice, group_order: go2)

      post_with_defaults :create, params: { order_ids_for_multi_order: [o1.id, o2.id] }, xhr: true, format: :js

      expect(response).to be_successful
      expect(flash[:alert]).to eq(I18n.t('multi_orders.create.merge_not_possible_invoices_present'))
    end
  end

  describe 'DELETE #destroy' do
    it 'blocks deletion when invoices exist' do
      o1 = create(:order, supplier: supplier, article_ids: [article.id])
      o2 = create(:order, supplier: supplier, article_ids: [article.id])
      create(:group_order, order: o1, ordergroup: user.ordergroup)
      create(:group_order, order: o2, ordergroup: user.ordergroup)
      o1.update!(state: 'closed')
      o2.update!(state: 'closed')
      multi = create(:multi_order, orders: [o1, o2])
      mgo = multi.multi_group_orders.first
      OrdergroupInvoice.create!(multi_group_order: mgo)

      delete_with_defaults :destroy, params: { id: multi.id }

      expect(flash[:alert]).to eq(I18n.t('multi_orders.destroy.invoices_left'))
      expect(MultiOrder.exists?(multi.id)).to be(true)
    end
  end

  describe 'GET #generate_ordergroup_invoices' do
    it 'invokes creation and redirects with notice' do
      o1 = create(:order, supplier: supplier, article_ids: [article.id])
      o2 = create(:order, supplier: supplier, article_ids: [article.id])
      create(:group_order, order: o1, ordergroup: user.ordergroup)
      create(:group_order, order: o2, ordergroup: user.ordergroup)
      o1.update!(state: 'closed')
      o2.update!(state: 'closed')
      multi = create(:multi_order, orders: [o1, o2])

      # Workaround: Stub creation to avoid dependency on view/overrides
      allow(OrdergroupInvoice).to receive(:create!).and_return(instance_double(OrdergroupInvoice))

      get_with_defaults :generate_ordergroup_invoices, params: { id: multi.id }

      expect(response).to redirect_to(finance_order_index_path)
      expect(flash[:notice]).to eq(I18n.t('finance.balancing.close.notice'))
    end
  end

  describe 'GET #collective_direct_debit' do
    before do
      FoodsoftConfig[:name] = 'Spec Coop'
      FoodsoftConfig[:group_order_invoices] = {
        iban: 'DE02120300000000202051',
        bic: 'BYLADEM1001',
        creditor_identifier: 'DE98ZZZ09999999999',
        payment_method: 'SEPA'
      }
    end

    it 'returns xml and marks invoices when mode all' do
      o1 = create(:order, supplier: supplier, article_ids: [article.id])
      create(:group_order, order: o1, ordergroup: user.ordergroup)
      o1.update!(state: 'closed')
      multi = create(:multi_order, orders: [o1])
      mgo = multi.multi_group_orders.first
      OrdergroupInvoice.create!(multi_group_order: mgo)

      xml_double = instance_double(OrderCollectiveDirectDebitXml, xml_string: '<xml>ok</xml>')
      allow(OrderCollectiveDirectDebitXml).to receive(:new).and_return(xml_double)

      get_with_defaults :collective_direct_debit, params: { id: multi.id, mode: 'all' }, format: :xml

      expect(response.media_type).to eq('text/xml')
      expect(response.body).to eq('<xml>ok</xml>')
      expect(mgo.reload.ordergroup_invoice.sepa_downloaded).to be(true)
    end

    it 'redirects with alert when SEPA not ready' do
      FoodsoftConfig[:group_order_invoices] = {}
      get_with_defaults :collective_direct_debit, params: { id: 1 }, format: :html
      expect(response).to redirect_to(finance_order_index_path)
      expect(flash[:alert]).to eq(I18n.t('activerecord.attributes.group_order_invoice.links.sepa_not_ready'))
    end

    it 'returns error json and unmarks on StandardError' do
      o1 = create(:order, supplier: supplier, article_ids: [article.id])
      create(:group_order, order: o1, ordergroup: user.ordergroup)
      o1.update!(state: 'closed')
      multi = create(:multi_order, orders: [o1])
      mgo = multi.multi_group_orders.first
      inv = OrdergroupInvoice.create!(multi_group_order: mgo)
      inv.update!(sepa_downloaded: true)

      allow(OrderCollectiveDirectDebitXml).to receive(:new).and_raise(StandardError, 'boom')

      get_with_defaults :collective_direct_debit, params: { id: multi.id, mode: 'all' }, format: :xml

      # Controller renders json on XML format errors; response may be considered xml by Rails stack
      # Accept both application/json and application/xml when JSON body is sent
      expect(response.media_type).to(satisfy { |mt| %w[application/json application/xml].include?(mt) })
      expect(JSON.parse(response.body)['error']).to be_present
      expect(mgo.reload.ordergroup_invoice.sepa_downloaded).to be(false)
    end
  end
end
