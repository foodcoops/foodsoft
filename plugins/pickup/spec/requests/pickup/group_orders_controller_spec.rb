# encoding: utf-8
require 'spec_helper'

# The pickup app API. Written as a plain request spec rather than rswag: the
# response is app-shaped (a nested serializer), and the plugin is not part of
# the core swagger documentation the api specs build.
describe Pickup::GroupOrdersController do
  let(:scope) { FoodsoftConfig.scope }
  let(:ordergroup) { create(:ordergroup, user_ids: [create(:user).id]) }
  let(:member) { create(:user, groups: [ordergroup]) }
  let(:other_ordergroup) { create(:ordergroup) }
  let(:other_member) { create(:user, groups: [other_ordergroup]) }

  # An order that has ended but whose pickup is still ahead.
  let(:order) do
    create(:order, article_count: 2, starts: 3.weeks.ago, ends: 2.days.ago,
                   pickup: Time.zone.now.to_date, state: 'finished')
  end
  let(:group_order) { create(:group_order, ordergroup: ordergroup, order: order) }
  let(:group_order_articles) do
    order.order_articles.first(2).map do |oa|
      create(:group_order_article, group_order: group_order, order_article: oa, quantity: 2, tolerance: 1)
    end
  end

  before { group_order_articles }

  # Token of +usr+ with the given scopes.
  def auth_for(usr, scopes)
    token = create(:oauth2_access_token, resource_owner_id: usr.id, scopes: scopes.join(' ')).token
    { 'Authorization' => "Bearer #{token}" }
  end

  def api_get(headers = auth_for(member, %w[group_orders:user]), params = {})
    get "/#{scope}/pickup/group_orders", params: { foodcoop: scope }.merge(params), headers: headers
  end

  def json_body
    JSON.parse(response.body)
  end

  describe 'GET /pickup/group_orders' do
    it 'lists the group orders of my ordergroup that are waiting for pickup' do
      api_get

      expect(json_body['group_orders'].map { |go| go['id'] }).to eq [group_order.id]
      article = json_body['group_orders'].first['articles'].first
      expect(article['ordered']).to eq 2
      expect(article['tolerance']).to eq 1
      expect(article['name']).to eq order.order_articles.first.article_version.name
      expect(article['received']).to eq group_order_articles.first.result.to_i
    end

    it 'shows the order note rather than the supplier note' do
      order.update!(note: 'pick up at the back door')

      api_get

      expect(json_body['group_orders'].first['note']).to eq 'pick up at the back door'
    end

    it 'does not include group orders of another ordergroup' do
      create(:group_order, ordergroup: other_ordergroup, order: order)

      api_get

      expect(json_body['group_orders'].map { |go| go['id'] }).to eq [group_order.id]
    end

    it 'has no way to ask for another ordergroup' do
      create(:group_order, ordergroup: other_ordergroup, order: order)

      api_get auth_for(member, %w[group_orders:user orders:write]), ordergroup_id: other_ordergroup.id

      # The parameter is not read at all -- the endpoint is about the caller's
      # own ordergroup, so an app cannot be talked into fetching another one.
      expect(json_body['group_orders'].map { |go| go['id'] }).to eq [group_order.id]
    end

    it 'does not list orders that have not ended yet' do
      future = create(:order, article_count: 1, starts: Time.zone.now, ends: 3.days.from_now,
                              pickup: 4.days.from_now.to_date, state: 'open')
      create(:group_order, ordergroup: ordergroup, order: future)

      api_get

      expect(json_body['group_orders'].map { |go| go['id'] }).to eq [group_order.id]
    end

    it 'does not list orders whose pickup lies further back than the window' do
      old = create(:order, article_count: 1, starts: 20.weeks.ago, ends: 19.weeks.ago,
                           pickup: 19.weeks.ago.to_date, state: 'received')
      create(:group_order, ordergroup: ordergroup, order: old)

      api_get

      expect(json_body['group_orders'].map { |go| go['id'] }).to eq [group_order.id]
    end

    it 'is forbidden for a user without an ordergroup' do
      api_get auth_for(create(:user), %w[group_orders:user])

      expect(response).to have_http_status(:forbidden)
    end

    it 'needs a token' do
      get "/#{scope}/pickup/group_orders", params: { foodcoop: scope }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'needs a scope that allows reading group orders' do
      api_get auth_for(member, %w[user:read])

      expect(response).to have_http_status(:forbidden)
    end

    it 'is off unless the foodcoop enables the plugin' do
      with_enabled(false) do
        api_get

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  def with_enabled(value)
    was = FoodsoftConfig[:use_pickup]
    FoodsoftConfig.config[:use_pickup] = value
    yield
  ensure
    FoodsoftConfig.config[:use_pickup] = was
  end
end
