# frozen_string_literal: true

require 'spec_helper'

describe Finance::OrdergroupsController do
  let(:user) { create(:user, :role_finance, :role_orders, :ordergroup) }
  let(:fin_trans_type1) { create(:financial_transaction_type) }
  let(:fin_trans_type2) { create(:financial_transaction_type) }
  let(:fin_trans1) do
    create(:financial_transaction,
           user: user,
           ordergroup: user.ordergroup,
           financial_transaction_type: fin_trans_type1)
  end
  let(:fin_trans2) do
    create(:financial_transaction,
           user: user,
           ordergroup: user.ordergroup,
           financial_transaction_type: fin_trans_type1)
  end
  let(:fin_trans3) do
    create(:financial_transaction,
           user: user,
           ordergroup: user.ordergroup,
           financial_transaction_type: fin_trans_type2)
  end

  before { login user }

  describe 'GET index' do
    before do
      fin_trans1
      fin_trans2
      fin_trans3
    end

    it 'renders index page' do
      get_with_defaults :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template('finance/ordergroups/index')
    end

    it 'calculates total balance sums correctly' do
      get_with_defaults :index
      expect(assigns(:total_balances).size).to eq(2)
      expect(assigns(:total_balances)[fin_trans_type1.id]).to eq(fin_trans1.amount + fin_trans2.amount)
      expect(assigns(:total_balances)[fin_trans_type2.id]).to eq(fin_trans3.amount)
    end
  end
end
