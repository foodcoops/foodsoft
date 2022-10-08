require 'spec_helper'

# Most routes are tested in the swagger_spec, this tests endpoints that change data.
describe Api::V1::User::GroupOrderArticlesController, type: :controller do
  include ApiOAuth
  let(:user) { create(:user, :ordergroup) }
  let(:json_goa) { json_response['group_order_article'] }
  let(:json_oa) { json_response['order_article'] }
  let(:api_scopes) { ['group_orders:user'] }

  let(:order) { create(:order, article_count: 1) }
  let(:oa_1) { order.order_articles.first }

  let(:other_quantity) { rand(1..10) }
  let(:other_tolerance) { rand(1..10) }
  let(:user_other) { create(:user, :ordergroup) }
  let!(:go_other) { create(:group_order, order: order, ordergroup: user_other.ordergroup) }
  let!(:goa_other) { create(:group_order_article, group_order: go_other, order_article: oa_1, quantity: other_quantity, tolerance: other_tolerance) }

  before { go_other.update_price!; user_other.ordergroup.update_stats! }

  shared_examples "group_order_articles endpoint success" do
    before { request }

    it "returns status 200" do
      expect(response).to have_http_status :ok
    end

    it "returns the order_article" do
      expect(json_oa['id']).to eq oa_1.id
      expect(json_oa['quantity']).to eq new_quantity + other_quantity
      expect(json_oa['tolerance']).to eq new_tolerance + other_tolerance
    end

    it "updates the group_order" do
      go = nil
      expect {
        request
        go = user.ordergroup.group_orders.where(order: order).last
      }.to change { go&.updated_by }.to(user)
                                    .and change { go&.price }
    end
  end

  shared_examples "group_order_articles create/update success" do
    include_examples "group_order_articles endpoint success"

    it "returns the group_order_article" do
      expect(json_goa['id']).to be_present
      expect(json_goa['order_article_id']).to eq oa_1.id
      expect(json_goa['quantity']).to eq new_quantity
      expect(json_goa['tolerance']).to eq new_tolerance
    end

    it "updates the group_order_article" do
      resulting_goa = GroupOrderArticle.where(id: json_goa['id']).first
      expect(resulting_goa).to be_present
      expect(resulting_goa.quantity).to eq new_quantity
      expect(resulting_goa.tolerance).to eq new_tolerance
    end
  end

  shared_examples "group_order_articles endpoint failure" do |status|
    it "returns status #{status}" do
      request
      expect(response.status).to eq status
    end

    it "does not change the group_order" do
      expect { request }.to_not change {
        go = user.ordergroup.group_orders.where(order: order).last
        go&.attributes
      }
    end

    it "does not change the group_order_article" do
      expect { request }.to_not change {
        goa = GroupOrderArticle.joins(:group_order)
                               .where(order_article_id: oa_1.id, group_orders: { ordergroup: user.ordergroup }).last
        goa&.attributes
      }
    end
  end

  describe "POST :create" do
    let(:new_quantity) { rand(1..10) }
    let(:new_tolerance) { rand(1..10) }

    let(:goa_params) { { order_article_id: oa_1.id, quantity: new_quantity, tolerance: new_tolerance } }
    let(:request) { post :create, params: { group_order_article: goa_params, foodcoop: 'f' } }

    context "with no existing group_order" do
      include_examples "group_order_articles create/update success"
    end

    context "with an existing group_order" do
      let!(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }

      include_examples "group_order_articles create/update success"
    end

    context "with an existing group_order_article" do
      let!(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }
      let!(:goa) { create(:group_order_article, group_order: go, order_article: oa_1, quantity: 0, tolerance: 1) }

      before { go.update_price!; user.ordergroup.update_stats! }

      include_examples "group_order_articles endpoint failure", 422
    end

    context "with invalid parameter values" do
      let(:goa_params) { { order_article_id: oa_1.id, quantity: -1, tolerance: new_tolerance } }

      include_examples "group_order_articles endpoint failure", 422
    end

    context 'with a closed order' do
      let(:order) { create(:order, article_count: 1, state: :finished) }

      include_examples "group_order_articles endpoint failure", 404
    end

    context 'without enough balance' do
      before { FoodsoftConfig[:minimum_balance] = 1000 }

      include_examples "group_order_articles endpoint failure", 403
    end

    context 'without enough apple points' do
      before { allow_any_instance_of(Ordergroup).to receive(:not_enough_apples?).and_return(true) }

      include_examples "group_order_articles endpoint failure", 403
    end
  end

  describe "PATCH :update" do
    let(:new_quantity) { rand(2..10) }
    let(:goa_params) { { quantity: new_quantity, tolerance: new_tolerance } }
    let(:request) { patch :update, params: { id: goa.id, group_order_article: goa_params, foodcoop: 'f' } }
    let(:new_tolerance) { rand(2..10) }

    let!(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }
    let!(:goa) { create(:group_order_article, group_order: go, order_article: oa_1, quantity: 1, tolerance: 0) }

    before { go.update_price!; user.ordergroup.update_stats! }

    context "happy flow" do
      include_examples "group_order_articles create/update success"
    end

    context "with invalid parameter values" do
      let(:goa_params) { { order_article_id: oa_1.id, quantity: -1, tolerance: new_tolerance } }

      include_examples "group_order_articles endpoint failure", 422
    end

    context 'with a closed order' do
      let(:order) { create(:order, article_count: 1, state: :finished) }

      include_examples "group_order_articles endpoint failure", 404
    end

    context 'without enough balance' do
      before { FoodsoftConfig[:minimum_balance] = 1000 }

      include_examples "group_order_articles endpoint failure", 403
    end

    context 'without enough apple points' do
      before { allow_any_instance_of(Ordergroup).to receive(:not_enough_apples?).and_return(true) }

      include_examples "group_order_articles endpoint failure", 403
    end
  end

  describe "DELETE :destroy" do
    let(:new_quantity) { 0 }
    let(:request) { delete :destroy, params: { id: goa.id, foodcoop: 'f' } }
    let(:new_tolerance) { 0 }

    let!(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }
    let!(:goa) { create(:group_order_article, group_order: go, order_article: oa_1) }

    before { go.update_price!; user.ordergroup.update_stats! }

    shared_examples "group_order_articles destroy success" do
      include_examples "group_order_articles endpoint success"

      it "does not return the group_order_article" do
        expect(json_goa).to be_nil
      end

      it "deletes the group_order_article" do
        expect(GroupOrderArticle.where(id: goa.id)).to be_empty
      end
    end

    context "happy flow" do
      include_examples "group_order_articles destroy success"
    end

    context 'with a closed order' do
      let(:order) { create(:order, article_count: 1, state: :finished) }

      include_examples "group_order_articles endpoint failure", 404
    end

    context 'without enough balance' do
      before { FoodsoftConfig[:minimum_balance] = 1000 }

      include_examples "group_order_articles destroy success"
    end

    context 'without enough apple points' do
      before { allow_any_instance_of(Ordergroup).to receive(:not_enough_apples?).and_return(true) }

      include_examples "group_order_articles destroy success"
    end
  end
end
