# frozen_string_literal: true

require 'spec_helper'

describe Finance::BaseController, type: :controller do
  let(:user) { create :user, :role_finance, :role_orders, :ordergroup }

  before { login user }

  describe 'GET index' do
    let(:fin_trans) { create_list :financial_transaction, 3, user: user, ordergroup: user.ordergroup }
    let(:orders) { create_list :order, 2, state: 'finished' }
    let(:invoices) { create_list :invoice, 4 }

    before do
      fin_trans
      orders
      invoices
    end

    it 'renders index page' do
      get_with_defaults :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/index')
      expect(assigns(:financial_transactions).size).to eq(fin_trans.size)
      expect(assigns(:orders).size).to eq(orders.size)
      expect(assigns(:unpaid_invoices).size).to eq(invoices.size)
    end
  end
end
