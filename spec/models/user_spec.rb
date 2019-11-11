require_relative '../spec_helper'

describe User do

  it 'is correctly created' do
    user = create :user,
      nick: 'johnnydoe', first_name: 'Johnny', last_name: 'DoeBar',
      email: 'johnnydoe@foodcoop.test', phone: '+1234567890'
    expect(user.nick).to eq('johnnydoe')
    expect(user.first_name).to eq('Johnny')
    expect(user.last_name).to eq('DoeBar')
    expect(user.name).to eq('Johnny DoeBar')
    expect(user.email).to eq('johnnydoe@foodcoop.test')
    expect(user.phone).to eq('+1234567890')
  end

  describe 'does not have the role' do
    let(:user) { create :user }
    it 'admin'        do expect(user.role_admin?).to be_falsey end
    it 'finance'      do expect(user.role_finance?).to be_falsey end
    it 'article_meta' do expect(user.role_article_meta?).to be_falsey end
    it 'suppliers'    do expect(user.role_suppliers?).to be_falsey end
    it 'orders'       do expect(user.role_orders?).to be_falsey end
  end

  describe do
    let(:user) { create :user, password: 'blahblah' }

    it 'can authenticate with correct password' do
      expect(User.authenticate(user.nick, 'blahblah')).to be_truthy
    end
    it 'can not authenticate with incorrect password' do
      expect(User.authenticate(user.nick, 'foobar')).to be_nil
    end
    it 'can not authenticate with nil nick' do
      expect(User.authenticate(nil, 'blahblah')).to be_nil
    end
    it 'can not authenticate with nil password' do
      expect(User.authenticate(user.nick, nil)).to be_nil
    end
    it 'can not set a password without matching confirmation' do
      user.password = 'abcdefghij'
      user.password_confirmation = 'foobarxyz'
      expect(user).to be_invalid
    end
    it 'can set a password with matching confirmation' do
      user.password = 'abcdefghij'
      user.password_confirmation = 'abcdefghij'
      expect(user).to be_valid
    end

    it 'has a unique nick' do
      expect(build(:user, nick: user.nick, email: "x-#{user.email}")).to be_invalid
    end
    it 'has a unique email' do
      expect(build(:user, email: "#{user.email}")).to be_invalid
    end

    it 'can authenticate using email address' do
      expect(User.authenticate(user.email, 'blahblah')).to be_truthy
    end

    it 'can authenticate when there is no nick' do
      user.nick = nil
      expect(user).to be_valid
      expect(User.authenticate(user.email, 'blahblah')).to be_truthy
    end
  end

  describe 'admin' do
    let(:user) { create :admin }
    it 'default admin role' do expect(user.role_admin?).to be_truthy end
  end

end
