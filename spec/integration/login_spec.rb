require_relative '../spec_helper'

describe LoginController, :type => :feature do
  let(:user) { create :user }

  describe 'forgot password', :type => :feature do
    it 'is accessible' do
      get forgot_password_path
      expect(response).to be_success
    end

    it 'sends a reset email' do
      post reset_password_path, user: {email: user.email}
      email = ActionMailer::Base.deliveries.first
      expect((email.to rescue [])).to eq [user.email]
    end
  end

  describe 'reset password', :type => :feature do
    let(:token) { user.reset_password_token }
    let(:newpass) { user.new_random_password }
    before do
      post reset_password_path, user: {email: user.email}
      user.reload
    end

    it 'is accessible' do
      get new_password_path, id: user.id, token: token
      expect(response).to be_success
    end

    it 'is not accessible with wrong token' do
      get new_password_path, id: user.id, token: '123'
      expect(response).to_not be_success
    end

    it 'changes the password' do
      patch update_password_path, id: user.id, token: token, user: {password: newpass, password_confirmation: newpass}
      expect(page).to_not have_selector('.alert-error')
      expect(User.authenticate(user.email, newpass)).to eq user
    end
  end
end
