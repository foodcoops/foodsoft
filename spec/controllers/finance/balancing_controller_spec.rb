# frozen_string_literal: true

require 'spec_helper'

describe Finance::BalancingController, type: :controller do
  let(:user) { create :user, :role_finance, :role_orders, groups: [create(:ordergroup)] }

  before { login user }

  describe 'GET index' do
    let(:order) { create :order }

    it 'renders index page' do
      get_with_defaults :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/balancing/index')
    end
  end

  describe 'new balancing' do
    let(:supplier) { create :supplier }
    let(:article1) { create :article, name: 'AAAA', supplier: supplier, unit_quantity: 1 }
    let(:article2) { create :article, name: 'AAAB', supplier: supplier, unit_quantity: 1 }

    let(:order) { create :order, supplier: supplier, article_ids: [article1.id, article2.id] }

    let(:go1) { create :group_order, order: order }
    let(:go2) { create :group_order, order: order }
    let(:oa1) { order.order_articles.find_by_article_id(article1.id) }
    let(:oa2) { order.order_articles.find_by_article_id(article2.id) }
    let(:oa3) { order2.order_articles.find_by_article_id(article2.id) }
    let(:goa1) { create :group_order_article, group_order: go1, order_article: oa1 }
    let(:goa2) { create :group_order_article, group_order: go1, order_article: oa2 }

    before do
      goa1.update_quantities(3, 0)
      goa2.update_quantities(1, 0)
      oa1.update_results!
      oa2.update_results!
    end

    it 'renders new order page' do
      get_with_defaults :new, params: { order_id: order.id }
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/balancing/new')
    end

    it 'assigns sorting on articles' do
      sortings = [
        ['name', [oa1, oa2]],
        ['name_reverse', [oa2, oa1]],
        ['order_number', [oa1, oa2]],
        ['order_number_reverse', [oa1, oa2]] # just one order
      ]
      sortings.each do |sorting|
        get_with_defaults :new, params: { order_id: order.id, sort: sorting[0] }
        expect(response).to have_http_status(:success)
        expect(assigns(:articles).to_a).to eq(sorting[1])
      end
    end
  end

  describe 'update summary' do
    let(:order) { create(:order) }

    it 'shows the summary view' do
      get_with_defaults :update_summary, params: { id: order.id }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/balancing/update_summary')
    end
  end

  describe 'new_on_order' do
    let(:order) { create(:order) }
    let(:order_article) { order.order_articles.first }

    it 'calls article update' do
      get_with_defaults :new_on_order_article_update, params: { id: order.id, order_article_id: order_article.id }, xhr: true
      expect(response).not_to render_template(layout: 'application')
      expect(response).to render_template('finance/balancing/new_on_order_article_update')
    end

    it 'calls article create' do
      get_with_defaults :new_on_order_article_create, params: { id: order.id, order_article_id: order_article.id }, xhr: true
      expect(response).not_to render_template(layout: 'application')
      expect(response).to render_template('finance/balancing/new_on_order_article_create')
    end
  end

  describe 'edit_note' do
    let(:order) { create(:order) }

    it 'updates order note' do
      get_with_defaults :edit_note, params: { id: order.id, order: { note: 'Hello' } }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/balancing/edit_note')
    end
  end

  describe 'update_note' do
    let(:order) { create(:order) }

    it 'updates order note' do
      get_with_defaults :update_note, params: { id: order.id, order: { note: 'Hello' } }, xhr: true
      expect(response).to have_http_status(:success)
    end

    it 'redirects to edit note on failed update' do
      get_with_defaults :update_note, params: { id: order.id, order: { article_ids: nil } }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/balancing/edit_note')
    end
  end

  describe 'transport' do
    let(:order) { create(:order) }

    it 'calls the edit transport view' do
      get_with_defaults :edit_transport, params: { id: order.id }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/balancing/edit_transport')
    end

    it 'does redirect if order valid' do
      get_with_defaults :update_transport, params: { id: order.id, order: { ends: Time.now } }, xhr: true
      expect(response).to have_http_status(:redirect)
      expect(assigns(:order).errors.count).to eq(0)
      expect(response).to redirect_to(new_finance_order_path(order_id: order.id))
    end

    it 'does redirect if order invalid' do
      get_with_defaults :update_transport, params: { id: order.id, order: { starts: Time.now + 2, ends: Time.now } }, xhr: true
      expect(assigns(:order).errors.count).to eq(1)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_finance_order_path(order_id: order.id))
    end
  end

  describe 'confirm' do
    let(:order) { create(:order) }

    it 'renders the confirm template' do
      get_with_defaults :confirm, params: { id: order.id }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/balancing/confirm')
    end
  end

  describe 'close and update account balances' do
    let(:order) { create(:order) }
    let(:order1) { create(:order, ends: Time.now) }
    let(:fft) { create(:financial_transaction_type) }

    it 'does not close order if ends not set' do
      get_with_defaults :close, params: { id: order.id, type: fft.id }
      expect(assigns(:order)).not_to be_closed
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_finance_order_url(order_id: order.id))
    end

    it 'closes order' do
      get_with_defaults :close, params: { id: order1.id, type: fft.id }
      expect(assigns(:order)).to be_closed
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(finance_order_index_url)
    end
  end

  describe 'close direct' do
    let(:order) { create(:order) }

    it 'does not close order if already closed' do
      order.close_direct!(user)
      get_with_defaults :close_direct, params: { id: order.id }
      expect(assigns(:order)).to be_closed
    end

    it 'closes order directly' do
      get_with_defaults :close_direct, params: { id: order.id }
      expect(assigns(:order)).to be_closed
    end
  end

  describe 'close all direct' do
    let(:invoice) { create(:invoice) }
    let(:invoice1) { create(:invoice) }
    let(:order) { create(:order, state: 'finished', ends: Time.now + 2.hours, invoice: invoice) }
    let(:order1) { create(:order, state: 'finished', ends: Time.now + 2.hours) }

    before do
      order
      order1
    end

    it 'does close orders' do
      get_with_defaults :close_all_direct_with_invoice
      order.reload
      expect(order).to be_closed
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(finance_order_index_url)
    end

    it 'does not close orders when invoice not set' do
      get_with_defaults :close_all_direct_with_invoice
      order1.reload
      expect(order1).not_to be_closed
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(finance_order_index_url)
    end
  end
end
