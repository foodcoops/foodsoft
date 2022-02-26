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

  subject { SwaggerCheckerFile.instance_for Rails.root.join('doc', 'swagger.v1.yml') }

  context 'has valid paths' do
    context 'user' do
      let(:api_scopes) { ['user:read'] }
      # create multiple users to make sure we're getting the authenticated user, not just any
      let!(:other_user_1) { create :user }
      let!(:user)         { create :user }
      let!(:other_user_2) { create :user }

      it { is_expected.to validate(:get, '/user', 200, api_auth) }
      it { is_expected.to validate(:get, '/user', 401) }

      it_handles_invalid_token_and_scope(:get, '/user')
    end

    context 'user/financial_overview' do
      let(:api_scopes) { ['finance:user'] }
      let!(:user) { create :user, :ordergroup }

      it { is_expected.to validate(:get, '/user/financial_overview', 200, api_auth) }
      it { is_expected.to validate(:get, '/user/financial_overview', 401) }

      it_handles_invalid_token_and_scope(:get, '/user/financial_overview')
    end

    context 'user/financial_transactions' do
      let(:api_scopes) { ['finance:user'] }
      let(:other_user) { create :user, :ordergroup }
      let!(:other_ft_1) { create :financial_transaction, ordergroup: other_user.ordergroup }

      context 'without ordergroup' do
        it { is_expected.to validate(:get, '/user/financial_transactions', 403, api_auth) }
        it { is_expected.to validate(:get, '/user/financial_transactions/{id}', 403, api_auth({ 'id' => other_ft_1.id })) }
      end

      context 'with ordergroup' do
        let(:user) { create :user, :ordergroup }
        let!(:ft_1) { create :financial_transaction, ordergroup: user.ordergroup }
        let!(:ft_2) { create :financial_transaction, ordergroup: user.ordergroup }
        let!(:ft_3) { create :financial_transaction, ordergroup: user.ordergroup }

        let(:create_params) { { '_data' => { financial_transaction: { amount: 1, financial_transaction_type_id: ft_1.financial_transaction_type.id, note: 'note' } } } }

        it { is_expected.to validate(:get, '/user/financial_transactions', 200, api_auth) }
        it { is_expected.to validate(:get, '/user/financial_transactions/{id}', 200, api_auth({ 'id' => ft_2.id })) }
        it { is_expected.to validate(:get, '/user/financial_transactions/{id}', 404, api_auth({ 'id' => other_ft_1.id })) }
        it { is_expected.to validate(:get, '/user/financial_transactions/{id}', 404, api_auth({ 'id' => FinancialTransaction.last.id + 1 })) }

        context 'without using self service' do
          it { is_expected.to validate(:post, '/user/financial_transactions', 403, api_auth(create_params)) }
        end

        context 'with using self service' do
          before { FoodsoftConfig[:use_self_service] = true }

          it { is_expected.to validate(:post, '/user/financial_transactions', 200, api_auth(create_params)) }

          context 'with invalid financial transaction type' do
            let(:create_params) { { '_data' => { financial_transaction: { amount: 1, financial_transaction_type_id: -1, note: 'note' } } } }

            it { is_expected.to validate(:post, '/user/financial_transactions', 404, api_auth(create_params)) }
          end

          context 'without note' do
            let(:create_params) { { '_data' => { financial_transaction: { amount: 1, financial_transaction_type_id: ft_1.financial_transaction_type.id } } } }

            it { is_expected.to validate(:post, '/user/financial_transactions', 422, api_auth(create_params)) }
          end

          context 'without enough balance' do
            before { FoodsoftConfig[:minimum_balance] = 1000 }

            it { is_expected.to validate(:post, '/user/financial_transactions', 403, api_auth(create_params)) }
          end
        end

        it_handles_invalid_token_and_scope(:get, '/user/financial_transactions')
        it_handles_invalid_token_and_scope(:post, '/user/financial_transactions', -> { api_auth(create_params) })
        it_handles_invalid_token_and_scope(:get, '/user/financial_transactions/{id}', -> { api_auth('id' => ft_2.id) })
      end
    end

    context 'user/group_order_articles' do
      let(:api_scopes) { ['group_orders:user'] }
      let(:order) { create(:order, article_count: 2) }

      let(:user_2) { create :user, :ordergroup }
      let(:group_order_2) { create(:group_order, order: order, ordergroup: user_2.ordergroup) }
      let!(:goa_2) { create :group_order_article, order_article: order.order_articles[0], group_order: group_order_2 }

      before { group_order_2.update_price!; user_2.ordergroup.update_stats! }

      context 'without ordergroup' do
        it { is_expected.to validate(:get, '/user/group_order_articles', 403, api_auth) }
        it { is_expected.to validate(:get, '/user/group_order_articles/{id}', 403, api_auth({ 'id' => goa_2.id })) }
      end

      context 'with ordergroup' do
        let(:user) { create :user, :ordergroup }
        let(:update_params) { { 'id' => goa.id, '_data' => { group_order_article: { quantity: goa.quantity + 1, tolerance: 0 } } } }
        let(:create_params) { { '_data' => { group_order_article: { order_article_id: order.order_articles[1].id, quantity: 1 } } } }
        let(:group_order) { create(:group_order, order: order, ordergroup: user.ordergroup) }
        let!(:goa) { create :group_order_article, order_article: order.order_articles[0], group_order: group_order }

        before { group_order.update_price!; user.ordergroup.update_stats! }

        it { is_expected.to validate(:get, '/user/group_order_articles', 200, api_auth) }
        it { is_expected.to validate(:get, '/user/group_order_articles/{id}', 200, api_auth({ 'id' => goa.id })) }
        it { is_expected.to validate(:get, '/user/group_order_articles/{id}', 404, api_auth({ 'id' => goa_2.id })) }
        it { is_expected.to validate(:get, '/user/group_order_articles/{id}', 404, api_auth({ 'id' => GroupOrderArticle.last.id + 1 })) }

        it { is_expected.to validate(:post, '/user/group_order_articles', 200, api_auth(create_params)) }
        it { is_expected.to validate(:patch, '/user/group_order_articles/{id}', 200, api_auth(update_params)) }
        it { is_expected.to validate(:delete, '/user/group_order_articles/{id}', 200, api_auth({ 'id' => goa.id })) }

        context 'with an existing group_order_article' do
          let(:create_params) { { '_data' => { group_order_article: { order_article_id: order.order_articles[0].id, quantity: 1 } } } }

          it { is_expected.to validate(:post, '/user/group_order_articles', 422, api_auth(create_params)) }
        end

        context 'with invalid parameter values' do
          let(:create_params) { { '_data' => { group_order_article: { order_article_id: order.order_articles[0].id, quantity: -1 } } } }
          let(:update_params) { { 'id' => goa.id, '_data' => { group_order_article: { quantity: -1, tolerance: 0 } } } }

          it { is_expected.to validate(:post, '/user/group_order_articles', 422, api_auth(create_params)) }
          it { is_expected.to validate(:patch, '/user/group_order_articles/{id}', 422, api_auth(update_params)) }
        end

        context 'with a closed order' do
          let(:order) { create(:order, article_count: 2, state: :finished) }

          it { is_expected.to validate(:post, '/user/group_order_articles', 404, api_auth(create_params)) }
          it { is_expected.to validate(:patch, '/user/group_order_articles/{id}', 404, api_auth(update_params)) }
          it { is_expected.to validate(:delete, '/user/group_order_articles/{id}', 404, api_auth({ 'id' => goa.id })) }
        end

        context 'without enough balance' do
          before { FoodsoftConfig[:minimum_balance] = 1000 }

          it { is_expected.to validate(:post, '/user/group_order_articles', 403, api_auth(create_params)) }
          it { is_expected.to validate(:patch, '/user/group_order_articles/{id}', 403, api_auth(update_params)) }
          it { is_expected.to validate(:delete, '/user/group_order_articles/{id}', 200, api_auth({ 'id' => goa.id })) }
        end

        context 'without enough apple points' do
          before { allow_any_instance_of(Ordergroup).to receive(:not_enough_apples?).and_return(true) }

          it { is_expected.to validate(:post, '/user/group_order_articles', 403, api_auth(create_params)) }
          it { is_expected.to validate(:patch, '/user/group_order_articles/{id}', 403, api_auth(update_params)) }
          it { is_expected.to validate(:delete, '/user/group_order_articles/{id}', 200, api_auth({ 'id' => goa.id })) }
        end

        it_handles_invalid_token_and_scope(:get, '/user/group_order_articles')
        it_handles_invalid_token_and_scope(:post, '/user/group_order_articles', -> { api_auth(create_params) })
        it_handles_invalid_token_and_scope(:get, '/user/group_order_articles/{id}', -> { api_auth({ 'id' => goa.id }) })
        it_handles_invalid_token_and_scope(:patch, '/user/group_order_articles/{id}', -> { api_auth(update_params) })
        it_handles_invalid_token_and_scope(:delete, '/user/group_order_articles/{id}', -> { api_auth({ 'id' => goa.id }) })
      end
    end

    context 'config' do
      let(:api_scopes) { ['config:user'] }

      it { is_expected.to validate(:get, '/config', 200, api_auth) }
      it { is_expected.to validate(:get, '/config', 401) }

      it_handles_invalid_token_and_scope(:get, '/config')
    end

    context 'navigation' do
      it { is_expected.to validate(:get, '/navigation', 200, api_auth) }
      it { is_expected.to validate(:get, '/navigation', 401) }

      it_handles_invalid_token(:get, '/navigation')
    end

    context 'financial_transactions' do
      let(:api_scopes) { ['finance:read'] }
      let(:user) { create(:user, :role_finance) }
      let(:other_user) { create :user, :ordergroup }
      let!(:ft_1) { create :financial_transaction, ordergroup: other_user.ordergroup }
      let!(:ft_2) { create :financial_transaction, ordergroup: other_user.ordergroup }

      it { is_expected.to validate(:get, '/financial_transactions', 200, api_auth) }
      it { is_expected.to validate(:get, '/financial_transactions/{id}', 200, api_auth({ 'id' => ft_2.id })) }
      it { is_expected.to validate(:get, '/financial_transactions/{id}', 404, api_auth({ 'id' => FinancialTransaction.last.id + 1 })) }

      context 'without role_finance' do
        let(:user) { create(:user) }

        it { is_expected.to validate(:get, '/financial_transactions', 403, api_auth) }
        it { is_expected.to validate(:get, '/financial_transactions/{id}', 403, api_auth({ 'id' => ft_2.id })) }
      end

      it_handles_invalid_token_and_scope(:get, '/financial_transactions')
      it_handles_invalid_token_and_scope(:get, '/financial_transactions/{id}', -> { api_auth({ 'id' => ft_2.id }) })
    end

    context 'financial_transaction_classes' do
      let!(:cla_1) { create :financial_transaction_class }
      let!(:cla_2) { create :financial_transaction_class }

      it { is_expected.to validate(:get, '/financial_transaction_classes', 200, api_auth) }
      it { is_expected.to validate(:get, '/financial_transaction_classes/{id}', 200, api_auth({ 'id' => cla_2.id })) }
      it { is_expected.to validate(:get, '/financial_transaction_classes/{id}', 404, api_auth({ 'id' => cla_2.id + 1 })) }

      it_handles_invalid_token(:get, '/financial_transaction_classes')
      it_handles_invalid_token(:get, '/financial_transaction_classes/{id}', -> { api_auth({ 'id' => cla_1.id }) })
    end

    context 'financial_transaction_types' do
      let!(:tpy_1) { create :financial_transaction_type }
      let!(:tpy_2) { create :financial_transaction_type }

      it { is_expected.to validate(:get, '/financial_transaction_types', 200, api_auth) }
      it { is_expected.to validate(:get, '/financial_transaction_types/{id}', 200, api_auth({ 'id' => tpy_2.id })) }
      it { is_expected.to validate(:get, '/financial_transaction_types/{id}', 404, api_auth({ 'id' => tpy_2.id + 1 })) }

      it_handles_invalid_token(:get, '/financial_transaction_types')
      it_handles_invalid_token(:get, '/financial_transaction_types/{id}', -> { api_auth({ 'id' => tpy_1.id }) })
    end

    context 'orders' do
      let(:api_scopes) { ['orders:read'] }
      let!(:order) { create :order }

      it { is_expected.to validate(:get, '/orders', 200, api_auth) }
      it { is_expected.to validate(:get, '/orders/{id}', 200, api_auth({ 'id' => order.id })) }
      it { is_expected.to validate(:get, '/orders/{id}', 404, api_auth({ 'id' => Order.last.id + 1 })) }

      it_handles_invalid_token_and_scope(:get, '/orders')
      it_handles_invalid_token_and_scope(:get, '/orders/{id}', -> { api_auth({ 'id' => order.id }) })
    end

    context 'order_articles' do
      let(:api_scopes) { ['orders:read'] }
      let!(:order_article) { create(:order, article_count: 1).order_articles.first }
      let!(:stock_article) { create(:stock_article) }
      let!(:stock_order_article) { create(:stock_order, article_ids: [stock_article.id]).order_articles.first }

      it { is_expected.to validate(:get, '/order_articles', 200, api_auth) }
      it { is_expected.to validate(:get, '/order_articles/{id}', 200, api_auth({ 'id' => order_article.id })) }
      it { is_expected.to validate(:get, '/order_articles/{id}', 200, api_auth({ 'id' => stock_order_article.id })) }
      it { is_expected.to validate(:get, '/order_articles/{id}', 404, api_auth({ 'id' => Article.last.id + 1 })) }

      it_handles_invalid_token_and_scope(:get, '/order_articles')
      it_handles_invalid_token_and_scope(:get, '/order_articles/{id}', -> { api_auth({ 'id' => order_article.id }) })
    end

    context 'article_categories' do
      let!(:cat_1) { create :article_category }
      let!(:cat_2) { create :article_category }

      it { is_expected.to validate(:get, '/article_categories', 200, api_auth) }
      it { is_expected.to validate(:get, '/article_categories/{id}', 200, api_auth({ 'id' => cat_2.id })) }
      it { is_expected.to validate(:get, '/article_categories/{id}', 404, api_auth({ 'id' => cat_2.id + 1 })) }

      it_handles_invalid_token(:get, '/article_categories')
      it_handles_invalid_token(:get, '/article_categories/{id}', -> { api_auth({ 'id' => cat_1.id }) })
    end
  end

  # needs to be last context so it is always run at the end
  context 'and finally' do
    it 'tests all documented routes' do
      is_expected.to validate_all_paths
    end
  end
end
