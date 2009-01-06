require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @admin = users(:admin)
  end
  
  def test_read_user
    assert_kind_of User, @admin
    assert_equal "Anton", @admin.first_name
    assert_equal "Admininistrator", @admin.last_name
    assert_equal "admin@foo.test", @admin.email
    assert @admin.role_admin?
  end

  def test_create_and_read_password
    @admin.set_password({:required => true}, "secret", "secret")
    @admin.save
    assert @admin.has_password("secret")
  end
  
  def test_invalid_password
    @admin.set_password({:required => true}, "foo", "foo")
    assert_equal 'Passwort muss zwischen 6 u. 25 Zeichen haben', @admin.errors.on_base
  end
  
  def test_password_not_match
    @admin.set_password({:required => true}, "foobar", "foobor")
    assert_equal 'Passworteingaben stimmen nicht überein', @admin.errors.on_base
  end
end
