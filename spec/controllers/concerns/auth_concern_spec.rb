# frozen_string_literal: true

require 'spec_helper'

class DummyAuthController < ApplicationController; end

describe 'Auth concern', type: :controller do
  controller DummyAuthController do
    # Defining a dummy action for an anynomous controller which inherits from the described class.
    def authenticate_blank
      authenticate
    end

    def authenticate_unknown_group
      authenticate('nooby')
    end

    def authenticate_pickups
      authenticate('pickups')
      head :ok unless performed?
    end

    def authenticate_finance_or_orders
      authenticate('finance_or_orders')
      head :ok unless performed?
    end

    def try_authenticate_membership_or_admin
      authenticate_membership_or_admin
    end

    def try_authenticate_or_token
      authenticate_or_token('xyz')
      head :ok unless performed?
    end

    def call_deny_access
      deny_access
    end

    def call_current_user
      current_user
    end

    def call_login_and_redirect_to_return_to
      user = User.find(params[:user_id])
      login_and_redirect_to_return_to(user)
    end

    def call_login
      user = User.find(params[:user_id])
      login(user)
    end
  end

  # unit testing protected/private methods
  describe 'protected/private methods' do
    let(:user) { create :user }
    let(:wrong_user) { create :user }

    describe '#current_user' do
      before do
        login user
        routes.draw { get 'call_current_user' => 'dummy_auth#call_current_user' }
      end

      describe 'with valid session' do
        it 'returns current_user' do
          get_with_defaults :call_current_user, params: { user_id: user.id }, format: JSON
          expect(assigns(:current_user)).to eq user
        end
      end

      describe 'with invalid session' do
        it 'not returns current_user' do
          session[:user_id] = nil
          get_with_defaults :call_current_user, params: { user_id: nil }, format: JSON
          expect(assigns(:current_user)).to be_nil
        end
      end
    end

    describe '#deny_access' do
      it 'redirects to root_url' do
        login user
        routes.draw { get 'deny_access' => 'dummy_auth#call_deny_access' }
        get_with_defaults :call_deny_access
        expect(response).to redirect_to(root_url)
      end
    end

    describe '#login' do
      before do
        routes.draw { get 'call_login' => 'dummy_auth#call_login' }
      end

      it 'sets user in session' do
        login wrong_user
        get_with_defaults :call_login, params: { user_id: user.id }, format: JSON
        expect(session[:user_id]).to eq user.id
        expect(session[:scope]).to eq FoodsoftConfig.scope
        expect(session[:locale]).to eq user.locale
      end
    end

    describe '#login_and_redirect_to_return_to' do
      it 'redirects to already set target' do
        login user
        session[:return_to] = my_profile_url
        routes.draw { get 'call_login_and_redirect_to_return_to' => 'dummy_auth#call_login_and_redirect_to_return_to' }
        get_with_defaults :call_login_and_redirect_to_return_to, params: { user_id: user.id }
        expect(session[:return_to]).to be_nil
      end
    end
  end

  describe 'authenticate' do
    describe 'not logged in' do
      it 'does not authenticate' do
        routes.draw { get 'authenticate_blank' => 'dummy_auth#authenticate_blank' }
        get_with_defaults :authenticate_blank
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to match(I18n.t('application.controller.error_authn'))
      end
    end

    describe 'logged in' do
      let(:user) { create :user }
      let(:pickups_user) { create :user, :role_pickups }
      let(:finance_user) { create :user, :role_finance }
      let(:orders_user) { create :user, :role_orders }

      it 'does not authenticate with unknown group' do
        login user
        routes.draw { get 'authenticate_unknown_group' => 'dummy_auth#authenticate_unknown_group' }
        get_with_defaults :authenticate_unknown_group
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(I18n.t('application.controller.error_denied', sign_in: ActionController::Base.helpers.link_to(I18n.t('application.controller.error_denied_sign_in'), login_path)))
      end

      it 'does not authenticate with pickups group' do
        login pickups_user
        routes.draw { get 'authenticate_pickups' => 'dummy_auth#authenticate_pickups' }
        get_with_defaults :authenticate_pickups
        expect(response).to have_http_status(:success)
      end

      it 'does not authenticate with finance group' do
        login finance_user
        routes.draw { get 'authenticate_finance_or_orders' => 'dummy_auth#authenticate_finance_or_orders' }
        get_with_defaults :authenticate_finance_or_orders
        expect(response).to have_http_status(:success)
      end

      it 'does not authenticate with orders group' do
        login orders_user
        routes.draw { get 'authenticate_finance_or_orders' => 'dummy_auth#authenticate_finance_or_orders' }
        get_with_defaults :authenticate_finance_or_orders
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'authenticate_membership_or_admin' do
    describe 'logged in' do
      let(:pickups_user) { create :user, :role_pickups }
      let(:workgroup) { create :workgroup }

      it 'redirects with not permitted group' do
        group_id = workgroup.id
        login pickups_user
        routes.draw { get 'try_authenticate_membership_or_admin' => 'dummy_auth#try_authenticate_membership_or_admin' }
        get_with_defaults :try_authenticate_membership_or_admin, params: { id: group_id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(I18n.t('application.controller.error_members_only'))
      end
    end
  end

  describe 'authenticate_or_token' do
    describe 'logged in' do
      let(:token_verifier) { TokenVerifier.new('xyz') }
      let(:token_msg) { token_verifier.generate }
      let(:user) { create :user }

      before { login user }

      it 'authenticates token' do
        routes.draw { get 'try_authenticate_or_token' => 'dummy_auth#try_authenticate_or_token' }
        get_with_defaults :try_authenticate_or_token, params: { token: token_msg }
        expect(response).not_to have_http_status(:redirect)
      end

      it 'redirects on faulty token' do
        routes.draw { get 'try_authenticate_or_token' => 'dummy_auth#try_authenticate_or_token' }
        get_with_defaults :try_authenticate_or_token, params: { token: 'abc' }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(I18n.t('application.controller.error_token'))
      end

      it 'authenticates current user on empty token' do
        routes.draw { get 'try_authenticate_or_token' => 'dummy_auth#try_authenticate_or_token' }
        get_with_defaults :try_authenticate_or_token
        expect(response).to have_http_status(:success)
      end
    end
  end
end
