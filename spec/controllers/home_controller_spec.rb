# frozen_string_literal: true

require 'spec_helper'

describe HomeController, type: :controller do
  let(:user) { create :user }

  describe 'GET index' do
    describe 'NOT logged in' do
      it 'redirects' do
        get_with_defaults :profile
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(login_path)
      end
    end

    describe 'logged in' do
      before { login user }

      it 'succeeds' do
        get_with_defaults :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET profile' do
    before { login user }

    it 'succeeds' do
      get_with_defaults :profile
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET reference_calculator' do
    describe 'with simple user' do
      before { login user }

      it 'redirects to home' do
        get_with_defaults :reference_calculator
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'with ordergroup user' do
      let(:og_user) { create :user, :ordergroup }

      before { login og_user }

      it 'succeeds' do
        get_with_defaults :reference_calculator
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET update_profile' do
    describe 'with simple user' do
      let(:unchanged_attributes) { user.attributes.slice('first_name', 'last_name', 'email') }
      let(:changed_attributes) { attributes_for :user }
      let(:invalid_attributes) { { email: 'e.mail.com' } }

      before { login user }

      it 'stays on profile after update with invalid attributes' do
        get_with_defaults :update_profile, params: { user: invalid_attributes }
        expect(response).to have_http_status(:success)
      end

      it 'redirects to profile after update with unchanged attributes' do
        get_with_defaults :update_profile, params: { user: unchanged_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(my_profile_path)
      end

      it 'redirects to profile after update' do
        patch :update_profile, params: { foodcoop: FoodsoftConfig[:default_scope], user: changed_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(my_profile_path)
        expect(flash[:notice]).to match(/#{I18n.t('home.changes_saved')}/)
        expect(user.reload.attributes.slice(:first_name, :last_name, :email)).to eq(changed_attributes.slice('first_name', 'last_name', 'email'))
      end
    end

    describe 'with ordergroup user' do
      let(:og_user) { create :user, :ordergroup }
      let(:unchanged_attributes) { og_user.attributes.slice('first_name', 'last_name', 'email') }
      let(:changed_attributes) { unchanged_attributes.merge({ ordergroup: { contact_address: 'new Adress 7' } }) }

      before { login og_user }

      it 'redirects to home after update' do
        get_with_defaults :update_profile, params: { user: changed_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(my_profile_path)
        expect(og_user.reload.ordergroup.contact_address).to eq('new Adress 7')
      end
    end
  end

  describe 'GET ordergroup' do
    describe 'with simple user' do
      before { login user }

      it 'redirects to home' do
        get_with_defaults :ordergroup
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'with ordergroup user' do
      let(:og_user) { create :user, :ordergroup }

      before { login og_user }

      it 'succeeds' do
        get_with_defaults :ordergroup
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET cancel_membership' do
    describe 'with simple user without group' do
      before { login user }

      it 'fails' do
        expect do
          get_with_defaults :cancel_membership
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect do
          get_with_defaults :cancel_membership, params: { membership_id: 424242 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'with ordergroup user' do
      let(:fin_user) { create :user, :role_finance }

      before { login fin_user }

      it 'removes user from group' do
        membership = fin_user.memberships.first
        get_with_defaults :cancel_membership, params: { group_id: fin_user.groups.first.id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(my_profile_path)
        expect(flash[:notice]).to match(/#{I18n.t('home.ordergroup_cancelled', group: membership.group.name)}/)
      end

      it 'removes user membership' do
        membership = fin_user.memberships.first
        get_with_defaults :cancel_membership, params: { membership_id: membership.id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(my_profile_path)
        expect(flash[:notice]).to match(/#{I18n.t('home.ordergroup_cancelled', group: membership.group.name)}/)
      end
    end
  end
end
