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
    let(:user) { create :user, password: 'blahblahblah' }

    it 'can authenticate with correct password' do
      expect(User.authenticate(user.nick, 'blahblahblah')).to be_truthy
    end

    it 'can not authenticate with incorrect password' do
      expect(User.authenticate(user.nick, 'foobar')).to be_nil
    end

    it 'can not authenticate with nil nick' do
      expect(User.authenticate(nil, 'blahblahblah')).to be_nil
    end

    it 'can not authenticate with nil password' do
      expect(User.authenticate(user.nick, nil)).to be_nil
    end

    it 'can not set a password without matching confirmation' do
      user.password = 'abcdefghijkl'
      user.password_confirmation = 'foobaruvwxyz'
      expect(user).to be_invalid
    end

    it 'can set a password with matching confirmation' do
      user.password = 'abcdefghijkl'
      user.password_confirmation = 'abcdefghijkl'
      expect(user).to be_valid
    end

    it 'has a unique nick' do
      expect(build(:user, nick: user.nick, email: "x-#{user.email}")).to be_invalid
    end

    it 'has a unique email' do
      expect(build(:user, email: "#{user.email}")).to be_invalid
    end

    it 'can authenticate using email address' do
      expect(User.authenticate(user.email, 'blahblahblah')).to be_truthy
    end

    it 'can authenticate when there is no nick' do
      user.nick = nil
      expect(user).to be_valid
      expect(User.authenticate(user.email, 'blahblahblah')).to be_truthy
    end
  end

  describe 'admin' do
    let(:user) { create :admin }

    it 'default admin role' do expect(user.role_admin?).to be_truthy end
  end

  describe 'sort correctly' do
    it 'by nick' do
      user_b = create :user, nick: 'bbb'
      user_a = create :user, nick: 'aaa'
      user_c = create :user, nick: 'ccc'

      expect(User.sort_by_param('nick')).to eq([user_a, user_b, user_c])
    end

    it 'reverse by nick' do
      user_b = create :user, nick: 'bbb'
      user_a = create :user, nick: 'aaa'
      user_c = create :user, nick: 'ccc'

      expect(User.sort_by_param('nick_reverse')).to eq([user_c, user_b, user_a])
    end

    it 'by name' do
      user_b = create :user, first_name: 'aaa', last_name: 'bbb'
      user_a = create :user, first_name: 'aaa', last_name: 'aaa'
      user_c = create :user, first_name: 'ccc', last_name: 'aaa'

      expect(User.sort_by_param('name')).to eq([user_a, user_b, user_c])
    end

    it 'reverse by name' do
      user_b = create :user, first_name: 'aaa', last_name: 'bbb'
      user_a = create :user, first_name: 'aaa', last_name: 'aaa'
      user_c = create :user, first_name: 'ccc', last_name: 'aaa'

      expect(User.sort_by_param('name_reverse')).to eq([user_c, user_b, user_a])
    end

    it 'by email' do
      user_b = create :user, email: 'bbb@dummy.com'
      user_a = create :user, email: 'aaa@dummy.com'
      user_c = create :user, email: 'ccc@dummy.com'

      expect(User.sort_by_param('email')).to eq([user_a, user_b, user_c])
    end

    it 'reverse by email' do
      user_b = create :user, email: 'bbb@dummy.com'
      user_a = create :user, email: 'aaa@dummy.com'
      user_c = create :user, email: 'ccc@dummy.com'

      expect(User.sort_by_param('email_reverse')).to eq([user_c, user_b, user_a])
    end

    it 'by phone' do
      user_b = create :user, phone: 'bbb'
      user_a = create :user, phone: 'aaa'
      user_c = create :user, phone: 'ccc'

      expect(User.sort_by_param('phone')).to eq([user_a, user_b, user_c])
    end

    it 'reverse by phone' do
      user_b = create :user, phone: 'bbb'
      user_a = create :user, phone: 'aaa'
      user_c = create :user, phone: 'ccc'

      expect(User.sort_by_param('phone_reverse')).to eq([user_c, user_b, user_a])
    end

    it 'by last_activity' do
      user_b = create :user, last_activity: 3.days.ago
      user_a = create :user, last_activity: 5.days.ago
      user_c = create :user, last_activity: Time.now

      expect(User.sort_by_param('last_activity')).to eq([user_a, user_b, user_c])
    end

    it 'reverse by last_activity' do
      user_b = create :user, last_activity: 3.days.ago
      user_a = create :user, last_activity: 5.days.ago
      user_c = create :user, last_activity: Time.now

      expect(User.sort_by_param('last_activity_reverse')).to eq([user_c, user_b, user_a])
    end

    it 'by ordergroup' do
      user_b = create :user, groups: [create(:workgroup, name: 'a'), create(:ordergroup, name: 'bb')]
      user_a = create :user, groups: [create(:workgroup, name: 'b'), create(:ordergroup, name: 'aa')]
      user_c = create :user, groups: [create(:workgroup, name: 'c'), create(:ordergroup, name: 'cc')]

      expect(User.sort_by_param('ordergroup')).to eq([user_a, user_b, user_c])
    end

    it 'reverse by ordergroup' do
      user_b = create :user, groups: [create(:workgroup, name: 'a'), create(:ordergroup, name: 'bb')]
      user_a = create :user, groups: [create(:workgroup, name: 'b'), create(:ordergroup, name: 'aa')]
      user_c = create :user, groups: [create(:workgroup, name: 'c'), create(:ordergroup, name: 'cc')]

      expect(User.sort_by_param('ordergroup_reverse')).to eq([user_c, user_b, user_a])
    end

    it 'and users are only listed once' do
      create :user

      expect(User.sort_by_param('ordergroup').size).to eq(1)
    end

    it 'and users belonging to a workgroup are only listed once' do
      create :admin

      expect(User.sort_by_param('ordergroup').size).to eq(1)
    end

    it 'and users belonging to 2 ordergroups are only listed once' do
      user = create :user
      create :ordergroup, user_ids: [user.id]
      create :ordergroup, user_ids: [user.id]

      expect(User.sort_by_param('ordergroup').size).to eq(1)
    end
  end
end
