require_relative '../spec_helper'

feature LoginController do
  let(:user) { create :user }

  describe 'forgot password' do
    before { visit forgot_password_path }

    it 'is accessible' do
      expect(page).to have_selector 'input[id=user_email]'
    end

    it 'sends a reset email' do
      fill_in 'user_email', with: user.email
      find('input[type=submit]').click
      expect(page).to have_selector '.alert-success'
      email = ActionMailer::Base.deliveries.first
      expect(email.to).to eq [user.email]
    end
  end

  describe 'and reset it' do
    let(:token) { user.reset_password_token }
    let(:newpass) { user.new_random_password }

    before { user.request_password_reset! }

    before { visit new_password_path(id: user.id, token: token) }

    it 'is accessible' do
      expect(page).to have_selector 'input[type=password]'
    end

    describe 'with wrong token' do
      let(:token) { 'foobar' }

      it 'is not accessible' do
        expect(page).to have_selector '.alert-error'
        expect(page).to_not have_selector 'input[type=password]'
      end
    end

    it 'changes the password' do
      fill_in 'user_password', with: newpass
      fill_in 'user_password_confirmation', with: newpass
      find('input[type=submit]').click
      expect(User.authenticate(user.email, newpass)).to eq user
    end
  end
end
