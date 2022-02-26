require 'spec_helper'

describe Api::V1::User::OrdergroupController, type: :controller do
  include ApiOAuth
  let(:user) { create :user, :ordergroup }
  let(:api_scopes) { ['finance:user'] }

  let(:ftc1) { create :financial_transaction_class }
  let(:ftc2) { create :financial_transaction_class }
  let(:ftt1) { create :financial_transaction_type, financial_transaction_class: ftc1 }
  let(:ftt2) { create :financial_transaction_type, financial_transaction_class: ftc2 }
  let(:ftt3) { create :financial_transaction_type, financial_transaction_class: ftc2 }

  describe "GET :financial_overview" do
    let(:order) { create(:order, article_count: 1) }
    let(:json_financial_overview) { json_response['financial_overview'] }
    let(:oa_1) { order.order_articles.first }

    let!(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }
    let!(:goa) { create(:group_order_article, group_order: go, order_article: oa_1, quantity: 1, tolerance: 0) }

    before { go.update_price!; user.ordergroup.update_stats! }

    before do
      og = user.ordergroup
      og.add_financial_transaction!(-1, '-1', user, ftt1)
      og.add_financial_transaction!(2, '2', user, ftt1)
      og.add_financial_transaction!(3, '3', user, ftt1)

      og.add_financial_transaction!(-10, '-10', user, ftt2)
      og.add_financial_transaction!(20, '20', user, ftt2)
      og.add_financial_transaction!(30, '30', user, ftt2)

      og.add_financial_transaction!(-100, '-100', user, ftt3)
      og.add_financial_transaction!(200, '200', user, ftt3)
      og.add_financial_transaction!(300, '300', user, ftt3)
    end

    it "returns correct values" do
      get :financial_overview, params: { foodcoop: 'f' }
      expect(json_financial_overview['account_balance']).to eq 444
      expect(json_financial_overview['available_funds']).to eq 444 - go.price

      ftcs = Hash[json_financial_overview['financial_transaction_class_sums'].map { |x| [x['id'], x] }]

      ftcs1 = ftcs[ftc1.id]
      expect(ftcs1['name']).to eq ftc1.name
      expect(ftcs1['amount']).to eq 4

      ftcs2 = ftcs[ftc2.id]
      expect(ftcs2['name']).to eq ftc2.name
      expect(ftcs2['amount']).to eq 440
    end
  end
end
