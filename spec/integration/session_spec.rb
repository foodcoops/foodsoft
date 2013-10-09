require_relative '../spec_helper'

describe 'the session', :type => :feature do
  let(:user) { create :user }

  describe 'login page', :type => :feature do
    it 'is accesible' do
      get login_path
      expect(response).to be_success
    end
    it 'logs me in' do
      login user
      expect(page).to_not have_selector('.alert-error')
    end
    it 'does not log me in with wrong password' do
      login user.nick, 'XX'+user.password 
      expect(page).to have_selector('.alert-error')
    end
  end

end
