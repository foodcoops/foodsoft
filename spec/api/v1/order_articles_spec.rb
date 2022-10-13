require 'spec_helper'

# Most routes are tested in the swagger_spec, this tests (non-ransack) parameters.
describe Api::V1::OrderArticlesController, type: :controller do
  include ApiOAuth
  let(:api_scopes) { ['orders:read'] }

  let(:json_order_articles) { json_response['order_articles'] }
  let(:json_order_article_ids) { json_order_articles.map { |joa| joa["id"] } }

  describe "GET :index" do
    context "with param q[ordered]" do
      let(:order) { create(:order, article_count: 4) }
      let(:order_articles) { order.order_articles }

      before do
        order_articles[0].update!(quantity: 0, tolerance: 0, units_to_order: 0)
        order_articles[1].update!(quantity: 1, tolerance: 0, units_to_order: 0)
        order_articles[2].update!(quantity: 0, tolerance: 1, units_to_order: 0)
        order_articles[3].update!(quantity: 0, tolerance: 0, units_to_order: 1)
      end

      it "(unset)" do
        get :index, params: { foodcoop: 'f' }
        expect(json_order_articles.count).to eq 4
      end

      it "all" do
        get :index, params: { foodcoop: 'f', q: { ordered: 'all' } }
        expect(json_order_article_ids).to match_array order_articles[1..2].map(&:id)
      end

      it "supplier" do
        get :index, params: { foodcoop: 'f', q: { ordered: 'supplier' } }
        expect(json_order_article_ids).to match_array [order_articles[3].id]
      end

      it "member" do
        get :index, params: { foodcoop: 'f', q: { ordered: 'member' } }
        expect(json_order_articles.count).to eq 0
      end

      context "when ordered by user" do
        let(:user) { create(:user, :ordergroup) }
        let(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }

        before do
          create(:group_order_article, group_order: go, order_article: order_articles[1], quantity: 1)
          create(:group_order_article, group_order: go, order_article: order_articles[2], tolerance: 0)
        end

        it "member" do
          get :index, params: { foodcoop: 'f', q: { ordered: 'member' } }
          expect(json_order_article_ids).to match_array order_articles[1..2].map(&:id)
        end
      end
    end
  end
end
