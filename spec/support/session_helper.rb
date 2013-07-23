
module SessionHelper

  def login(user=nil, password=nil)
    visit login_path
    user = FactoryGirl.create :user if user.nil?
    nick, password = user.nick, user.password if user.instance_of? ::User
    fill_in 'nick', :with => nick
    fill_in 'password', :with => password
    find('input[type=submit]').click
  end

end
