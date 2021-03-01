module SessionHelper
  def login(user = nil, password = nil)
    visit login_path
    user = FactoryBot.create :user if user.nil?
    if user.instance_of? ::User
      nick, password = user.nick, user.password
    else
      nick = user
    end
    fill_in 'nick', :with => nick
    fill_in 'password', :with => password
    find('input[type=submit]').click
  end
end
