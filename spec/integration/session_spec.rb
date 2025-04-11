require_relative '../spec_helper'

feature 'the session' do
  let(:user) { create(:user) }

  describe 'login page' do
    it 'is accessible' do
      visit login_path
      expect(page).to have_css('input[type=password]')
    end

    it 'logs me in' do
      login user
      expect(page).to have_no_css('.alert-error')
    end

    it 'does not log me in with wrong password' do
      login user.nick, 'XX' + user.password
      expect(page).to have_css('.alert-error')
    end

    it 'can log me in using an email address' do
      visit login_path
      fill_in 'nick', with: user.email
      fill_in 'password', with: user.password
      find('input[type=submit]').click
      expect(page).to have_no_css('.alert-error')
    end
  end
end
