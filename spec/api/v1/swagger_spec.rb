require 'spec_helper'
require 'apivore'

# we want to load a local file in YAML-format instead of a served JSON file
class SwaggerCheckerFile < Apivore::SwaggerChecker
  def fetch_swagger!
    YAML.load(File.read(swagger_path))
  end
end

describe 'API v1', type: :apivore, order: :defined do
  include ApiHelper

  subject { SwaggerCheckerFile.instance_for Rails.root.join('doc/swagger.v1.yml') }

  context 'has valid paths' do

    # users
    context do
      # create multiple users to make sure we're getting the authenticated user, not just any
      let!(:other_user_1) { create :user }
      let!(:user)         { create :user }
      let!(:other_user_2) { create :user }

      it { is_expected.to validate(:get, '/user', 200, auth) }
      it { is_expected.to validate(:get, '/user', 401) }

      context 'with invalid access token' do
        let(:access_token) { 'abc' }
        it { is_expected.to validate(:get, '/user', 401, auth) }
      end
    end

    # article_categories
    context do
      let!(:cat_1) { create :article_category }
      let!(:cat_2) { create :article_category }
      let!(:cat_3) { create :article_category }

      it { is_expected.to validate(:get, '/article_categories', 200, auth) }
      it { is_expected.to validate(:get, '/article_categories/{id}', 200, auth({'id' => cat_2.id})) }
      it { is_expected.to validate(:get, '/article_categories/{id}', 404, auth({'id' => cat_3.id + 1})) }
    end

    # orders
    context do
      let!(:order_1) { create :order, article_count: 1 }
      let!(:order_2) { create :order, article_count: 1 }
      let!(:order_3) { create :stock_order, article_count: 1 }
      let!(:order_4) { create :order, state: 'finished', article_count: 1 }
      let!(:order_5) { create :order, state: 'closed', article_count: 1 }

      it { is_expected.to validate(:get, '/orders', 200, auth) }
      it { is_expected.to validate(:get, '/orders/{id}', 200, auth({'id' => order_2.id})) }
      it { is_expected.to validate(:get, '/orders/{id}', 404, auth({'id' => order_4.id})) }
      it { is_expected.to validate(:get, '/orders/{id}', 404, auth({'id' => order_5.id})) }
      it { is_expected.to validate(:get, '/orders/{id}', 404, auth({'id' => Order.last.id + 1})) }
    end

    # order_articles
    context do
      let!(:order) { create :order, article_count: 3 + rand(10) }
      let(:oa_1) { order.order_articles[0] }
      let(:oa_2) { order.order_articles[1] }

      it { is_expected.to validate(:get, '/order_articles', 200, auth) }
      it { is_expected.to validate(:get, '/order_articles/{id}', 200, auth({'id' => oa_2.id})) }
      it { is_expected.to validate(:get, '/order_articles/{id}', 404, auth({'id' => OrderArticle.last.id + 1})) }
    end

    # group_order_articles
    context do
      let!(:order) { create :order, article_count: 3 }
      let(:oa_1) { order.order_articles[0] }
      let(:oa_2) { order.order_articles[1] }

      let(:other_go) { create :group_order, order: order }
      let!(:other_goa_1) { create :group_order_article, group_order: other_go, order_article: oa_1 }

      context 'without ordergroup' do
        it { is_expected.to validate(:get, '/group_order_articles', 403, auth) }
        it { is_expected.to validate(:get, '/group_order_articles/{id}', 403, auth({'id' => other_goa_1.id})) }
      end

      context 'in ordergroup' do
        let(:user) { create :user, :ordergroup }
        let(:go) { create :group_order, order: order, ordergroup: user.ordergroup }
        let!(:goa_1) { create :group_order_article, group_order: go, order_article: oa_1 }
        let!(:goa_2) { create :group_order_article, group_order: go, order_article: oa_2 }

        it { is_expected.to validate(:get, '/group_order_articles', 200, auth) }
        it { is_expected.to validate(:get, '/group_order_articles/{id}', 200, auth({'id' => goa_2.id})) }
        it { is_expected.to validate(:get, '/group_order_articles/{id}', 404, auth({'id' => other_goa_1.id})) }
        it { is_expected.to validate(:get, '/group_order_articles/{id}', 404, auth({'id' => GroupOrderArticle.last.id + 1})) }
      end
    end

    # @todo finish
  end

  # financial_transactions
  context do
    let(:other_user) { create :user, :ordergroup }
    let!(:other_ft_1) { create :financial_transaction, ordergroup: other_user.ordergroup }

    context 'without ordergroup' do
      it { is_expected.to validate(:get, '/financial_transactions', 403, auth) }
      it { is_expected.to validate(:get, '/financial_transactions/{id}', 403, auth({'id' => other_ft_1.id})) }
    end

    context 'in ordergroup' do
      let(:user) { create :user, :ordergroup }
      let!(:ft_1) { create :financial_transaction, ordergroup: user.ordergroup }
      let!(:ft_2) { create :financial_transaction, ordergroup: user.ordergroup }
      let!(:ft_3) { create :financial_transaction, ordergroup: user.ordergroup }

      it { is_expected.to validate(:get, '/financial_transactions', 200, auth) }
      it { is_expected.to validate(:get, '/financial_transactions/{id}', 200, auth({'id' => ft_2.id})) }
      it { is_expected.to validate(:get, '/financial_transactions/{id}', 404, auth({'id' => other_ft_1.id})) }
      it { is_expected.to validate(:get, '/financial_transactions/{id}', 404, auth({'id' => FinancialTransaction.last.id + 1})) }
    end
  end

  context 'and' do
    it 'tests all documented routes' do
      is_expected.to validate_all_paths
    end
  end
end
