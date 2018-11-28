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

    context 'financial_transactions' do
      let(:other_user) { create :user, :ordergroup }
      let!(:other_ft_1) { create :financial_transaction, ordergroup: other_user.ordergroup }

      context 'without ordergroup' do
        it { is_expected.to validate(:get, '/user/financial_transactions', 403, auth) }
        it { is_expected.to validate(:get, '/user/financial_transactions/{id}', 403, auth({'id' => other_ft_1.id})) }
      end

      context 'in ordergroup' do
        let(:user) { create :user, :ordergroup }
        let!(:ft_1) { create :financial_transaction, ordergroup: user.ordergroup }
        let!(:ft_2) { create :financial_transaction, ordergroup: user.ordergroup }
        let!(:ft_3) { create :financial_transaction, ordergroup: user.ordergroup }

        it { is_expected.to validate(:get, '/user/financial_transactions', 200, auth) }
        it { is_expected.to validate(:get, '/user/financial_transactions/{id}', 200, auth({'id' => ft_2.id})) }
        it { is_expected.to validate(:get, '/user/financial_transactions/{id}', 404, auth({'id' => other_ft_1.id})) }
        it { is_expected.to validate(:get, '/user/financial_transactions/{id}', 404, auth({'id' => FinancialTransaction.last.id + 1})) }
      end
    end

    context 'config' do
      it { is_expected.to validate(:get, '/config', 200, auth) }
      it { is_expected.to validate(:get, '/config', 401) }
    end

    context 'navigation' do
      it { is_expected.to validate(:get, '/navigation', 200, auth) }
      it { is_expected.to validate(:get, '/navigation', 401) }
    end
  end

  # needs to be last context so it is always run at the end
  context 'and finally' do
    it 'tests all documented routes' do
      is_expected.to validate_all_paths
    end
  end
end
