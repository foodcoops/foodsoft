require_relative '../spec_helper'

feature LoginController do
  let(:user) { create(:user) }

  describe 'forgot password' do
    before { visit forgot_password_path }

    it 'is accessible' do
      expect(page).to have_css 'input[id=user_email]'
    end

    it 'sends a reset email' do
      fill_in 'user_email', with: user.email
      find('input[type=submit]').click
      expect(page).to have_css '.alert-success'
      email = ActionMailer::Base.deliveries.first
      expect(email.to).to eq [user.email]
    end
  end

  describe 'and reset it' do
    let(:token) { user.reset_password_token }
    let(:newpass) { user.new_random_password }

    before do
      user.request_password_reset!
      visit new_password_path(id: user.id, token: token)
    end

    it 'is accessible' do
      expect(page).to have_css 'input[type=password]'
    end

    describe 'with wrong token' do
      let(:token) { 'foobar' }

      it 'is not accessible' do
        expect(page).to have_css '.alert-danger'
        expect(page).to have_no_css 'input[type=password]'
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
