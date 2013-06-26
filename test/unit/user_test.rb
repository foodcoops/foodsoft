require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

  def setup
    @admin = users(:admin)
  end
  
  test 'read_user' do
    assert_kind_of User, @admin
    assert_equal "Anton", @admin.first_name
    assert_equal "Admininistrator", @admin.last_name
    assert_equal "admin@foo.test", @admin.email
    assert @admin.role_admin?
  end

  test 'create_and_read_password' do
    @admin.password = "some_secret"
    @admin.password_confirmation = @admin.password
    assert @admin.valid?
    assert @admin.has_password("some_secret")
  end
  
  test 'invalid_password' do
    @admin.password = "foo"
    @admin.password_confirmation = @admin.password
    assert @admin.invalid?
    assert_equal [I18n.t('activemodel.errors.messages.too_short', count: 5)], @admin.errors[:password]
  end
  
  test 'password_not_match' do
    @admin.password = "foobar"
    @admin.password_confirmation = "foobor"
    @admin.save
    assert_equal [I18n.t('activemodel.errors.messages.confirmation')], @admin.errors[:password]
  end
end

