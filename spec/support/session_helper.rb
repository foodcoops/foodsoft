
module SessionHelper

  def login(nick=nil, password=nil)
    visit login_path
    if nick.nil?
      user = FactoryGirl.create :user
      nick, password = user.nick, user.password
    end
    fill_in 'nick', :with => nick
    fill_in 'password', :with => password
    find('input[type=submit]').click
  end

end
