require 'spec_helper'

describe User do

  it 'is correctly created' do
    user = FactoryGirl.create :user,
      nick: 'johnnydoe', first_name: 'Johnny', last_name: 'DoeBar',
      email: 'johnnydoe@foodcoop.test', phone: '+1234567890'
    user.nick.should == 'johnnydoe'
    user.first_name.should == 'Johnny'
    user.last_name.should == 'DoeBar'
    user.name.should == 'Johnny DoeBar'
    user.email.should == 'johnnydoe@foodcoop.test'
    user.phone.should == '+1234567890'
  end

  describe 'does not have the role' do
    let(:user) { FactoryGirl.create :user }
    it 'admin'        do user.role_admin?.should be_false end
    it 'finance'      do user.role_finance?.should be_false end
    it 'article_meta' do user.role_article_meta?.should be_false end
    it 'suppliers'    do user.role_suppliers?.should be_false end
    it 'orders'       do user.role_orders?.should be_false end
  end

  describe do
    let(:user) { FactoryGirl.create :user, password: 'blahblah' }

    it 'can authenticate with correct password' do
      User.authenticate(user.nick, 'blahblah').should be_true
    end
    it 'can not authenticate with incorrect password' do
      User.authenticate(user.nick, 'foobar').should be_nil
    end
    it 'can not set a password without confirmation' do
      user.password = 'abcdefghij'
      user.should_not be_valid
    end
    it 'can not set a password without matching confirmation' do
      user.password = 'abcdefghij'
      user.password_confirmation = 'foobarxyz'
      user.should_not be_valid
    end
    it 'can set a password with matching confirmation' do
      user.password = 'abcdefghij'
      user.password_confirmation = 'abcdefghij'
      user.should be_valid
    end

    it 'has a unique nick' do
      FactoryGirl.build(:user, nick: user.nick, email: "x-#{user.email}").should_not be_valid
    end
    it 'has a unique email' do
      FactoryGirl.build(:user, email: "#{user.email}").should_not be_valid
    end
  end

  describe 'admin' do
    let(:user) { FactoryGirl.create :admin }
    it 'default admin role' do user.role_admin?.should be_true end
  end

end
