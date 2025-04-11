# frozen_string_literal: true

require 'spec_helper'

describe Finance::OrdergroupsController do
  include ActionView::Helpers::NumberHelper
  render_views

  let(:user) { create(:user, :role_finance, :role_orders, :ordergroup) }
  let(:fin_trans_type1) { create(:financial_transaction_type) }
  let(:fin_trans_type2) { create(:financial_transaction_type) }
  let(:fin_trans1) do
    create(:financial_transaction,
           user: user,
           amount: 100,
           ordergroup: user.ordergroup,
           financial_transaction_type: fin_trans_type1)
  end
  let(:fin_trans2) do
    create(:financial_transaction,
           user: user,
           amount: 200,
           ordergroup: user.ordergroup,
           financial_transaction_type: fin_trans_type1)
  end
  let(:fin_trans3) do
    create(:financial_transaction,
           amount: 42.23,
           financial_transaction_type: fin_trans_type2)
  end
  let(:fin_trans_foodcoop) do
    create(:financial_transaction,
           amount: 111,
           ordergroup: nil,
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
    end

    it 'calculates total balance sums correctly' do
      get_with_defaults :index
      expect(response).to have_http_status(:success)

      assert_total_balance_of_transaction_type1(300)
      assert_total_balance_of_transaction_type2(42.23)
      assert_total_balance_sum(342.23)
    end

    it 'ignores deleted ordergroups' do
      user.ordergroup.mark_as_deleted
      get_with_defaults :index
      assert_total_balance_of_transaction_type1(0)
      assert_total_balance_of_transaction_type2(42.23)
      assert_select '#total_balance_sum', number_to_currency(42.23)
    end

    it 'ignores foodcoop transactions' do
      fin_trans_foodcoop
      get_with_defaults :index
      assert_total_balance_of_transaction_type1(300)
      assert_total_balance_of_transaction_type2(42.23)
      assert_select '#total_balance_sum', number_to_currency(342.23)
    end
  end

  def assert_total_balance_sum(amount)
    assert_select '#total_balance_sum', number_to_currency(amount)
  end

  def assert_total_balance_of_transaction_type1(amount)
    assert_total_balanceof_transaction_type(fin_trans_type1.financial_transaction_class_id, amount)
  end

  def assert_total_balance_of_transaction_type2(amount)
    assert_total_balanceof_transaction_type(fin_trans_type2.financial_transaction_class_id, amount)
  end

  def assert_total_balanceof_transaction_type(type, amount)
    assert_select "#total_balance#{type}", number_to_currency(amount)
  end
end
