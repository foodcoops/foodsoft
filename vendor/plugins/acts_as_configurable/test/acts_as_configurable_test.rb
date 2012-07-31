require 'test/unit'
require File.dirname(__FILE__) + '/test_helper'
require File.join(File.dirname(__FILE__), 'fixtures/entities')


class ActsAsConfigurableTest < Test::Unit::TestCase
  fixtures :test_users, :test_groups
  
  def setup
    @group = TestGroup.create(:display_name => 'Rails Core')
    @user = TestUser.create(:login => 'sam', :name => 'Sam Testuser', :email => 'sam@example.com')
  end
  
  SETTINGS = ActiveRecord::Base.const_get('ConfigurableSettings')
  TARGETEDSETTINGS = ActiveRecord::Base.const_get('TargetedSettings')
  PROXYSETTING = ActiveRecord::Base.const_get('ProxySetting')
  USR_CFG = {
    :how_many_time_i_eat_out_a_week => 4,
    'what i am made of' => 'steel',
    :friends => ['bob', 'ken']
  }
  GR_ROLES = ['creator', 'member', 'fundraiser']

  def test_user_model_settings
    
    assert_equal 'sam',             @user.login
    assert_equal 'Rails Core',      @group.display_name
    
    assert_equal 0,                 @user._configurable_settings.size
    assert_equal Array,             @user.settings.class
    assert_equal SETTINGS,          @user.settings.real_class
    assert_equal 0,                 @user.settings.size
    
    @user.settings[:config] = USR_CFG
    
    assert_equal 1,                 @user._configurable_settings.size
    assert_equal USR_CFG,           @user.settings[:config]
    assert_equal 1,                 @user.settings.size
    assert_equal Hash,              @user.settings[:config].class
    assert_equal PROXYSETTING,      @user.settings[:config].real_class
    assert_equal 3,                 @user.settings[:config].keys.size
    assert_equal 4,                 @user.settings[:config][:how_many_time_i_eat_out_a_week]
    assert_equal Array,             @user.settings[:config][:friends].class
    assert_equal 2,                 @user.settings[:config][:friends].size
    
    @user.settings[:my_group] = @group
    
    assert_equal 2,                 @user.settings.size
    assert_equal TestGroup,         @user.settings[:my_group].class
    
  end
  
  def test_new_each_with_key
    @user.settings[:config] = USR_CFG
    @user.settings.each_with_key do |key, setting|
      assert_equal :config.to_s, key
      assert_equal USR_CFG, setting
    end
  end
  
  
  def test_valid_raw_setting
    
    assert ConfigurableSetting.find(:first).nil?
    
    @user.settings[:config] = USR_CFG
    
    first_setting = ConfigurableSetting.find(:first)
    
    assert_equal 'config',          first_setting.name
    assert_equal 'TestUser',        first_setting.configurable_type
    assert_equal @user.id,          first_setting.configurable_id
    assert_equal nil,               first_setting.targetable_type
    assert_equal nil,               first_setting.targetable_id
    assert_equal USR_CFG.to_yaml,   first_setting.value
    
  end
  
  
  def test_associated_settings
    
    assert_equal [],                @user.settings
    assert_equal [],                @user.settings_for(@group)
    
    @user.settings_for(@group)[:roles] = GR_ROLES
    
    assert_equal GR_ROLES,          @user.settings_for(@group)[:roles]
    assert_equal 1,                 @user.settings_for(@group).size
    assert_equal 0,                 @user.settings.size
    
  end
  
  
  def test_associated_target_settings
    
    assert_equal [],                @group.targeted_settings
    assert_equal TARGETEDSETTINGS,  @group.targeted_settings.real_class
    
    @user.settings_for(@group)[:roles] = GR_ROLES
    
    assert_equal 1,                 @group._targetable_settings.size
    assert_equal 1,                 @group.targeted_settings.size
    assert_equal 1,                 @group.targeted_settings_for(@user).size
    assert_equal GR_ROLES,          @group.targeted_settings_for(@user)[:roles]
    @group.targeted_settings.each do |x| 
      assert x.owner == @user and x.target == @group and x.name == 'roles'
    end
    @group.targeted_settings.each do |x| 
      assert x == GR_ROLES
    end
    @group.targeted_settings[:roles].each do |x|
      assert x.owner == @user and x == GR_ROLES
    end
    
  end   
  
end