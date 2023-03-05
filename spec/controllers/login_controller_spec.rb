# frozen_string_literal: true

require 'spec_helper'

describe LoginController, type: :controller do
  let(:invite) { create :invite }

  describe 'GET accept_invitation' do
    let(:expired_invite) { create :expired_invite }

    describe 'with valid token' do
      it 'accepts invitation' do
        get_with_defaults :accept_invitation, params: { token: invite.token }
        expect(response).to have_http_status(:success)
        expect(response).to render_template('login/accept_invitation')
      end
    end

    describe 'with invalid token' do
      it 'redirects to login' do
        get_with_defaults :accept_invitation, params: { token: invite.token + 'XX' }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(login_url)
        expect(flash[:alert]).to match(I18n.t('login.controller.error_invite_invalid'))
      end
    end

    describe 'with timed out token' do
      it 'redirects to login' do
        get_with_defaults :accept_invitation, params: { token: expired_invite.token }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(login_url)
        expect(flash[:alert]).to match(I18n.t('login.controller.error_invite_invalid'))
      end
    end

    describe 'without group' do
      it 'redirects to login' do
        invite.group.destroy
        get_with_defaults :accept_invitation, params: { token: invite.token }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(login_url)
        expect(flash[:alert]).to match(I18n.t('login.controller.error_group_invalid'))
      end
    end
  end

  describe 'POST accept_invitation' do
    describe 'with invalid parameters' do
      it 'renders accept_invitation view' do
        post_with_defaults :accept_invitation, params: { token: invite.token, user: invite.user.slice('first_name') }
        expect(response).to have_http_status(:success)
        expect(response).to render_template('login/accept_invitation')
        expect(assigns(:user).errors.present?).to be true
      end
    end

    describe 'with valid parameters' do
      it 'redirects to login' do
        post_with_defaults :accept_invitation, params: { token: invite.token, user: invite.user.slice('first_name', 'password') }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(login_url)
        expect(flash[:notice]).to match(I18n.t('login.controller.accept_invitation.notice'))
      end
    end
  end
end
