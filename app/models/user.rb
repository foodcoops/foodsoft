# encoding: utf-8

require 'digest/sha1'
# specific user rights through memberships (see Group)
class User < ActiveRecord::Base
  #TODO: acts_as_paraniod ??
  
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  #has_one :ordergroup, :through => :memberships, :source => :group, :class_name => "Ordergroup"
  def ordergroup
    Ordergroup.joins(:memberships).where(memberships: {user_id: self.id}).first
  end

  has_many :workgroups, :through => :memberships, :source => :group, :class_name => "Workgroup"
  has_many :assignments, :dependent => :destroy
  has_many :tasks, :through => :assignments
  has_many :send_messages, :class_name => "Message", :foreign_key => "sender_id"
  has_many :pages, :foreign_key => 'updated_by'
  has_many :created_orders, :class_name => 'Order', :foreign_key => 'created_by_user_id', :dependent => :nullify
  
  attr_accessor :password, :setting_attributes

  validates_presence_of :nick, :email
  validates_presence_of :password, :on => :create
  validates_length_of :nick, :in => 2..25
  validates_uniqueness_of :nick, :case_sensitive => false
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :email, :case_sensitive => false
  validates_length_of :first_name, :in => 2..50
  validates_confirmation_of :password
  validates_length_of :password, :in => 5..25, :allow_blank => true

  before_validation :set_password
  after_save :update_settings

  # Adds support for configuration settings (through "settings" attribute).
  acts_as_configurable
  
  # makes the current_user (logged-in-user) available in models
  cattr_accessor :current_user
  
  # User settings keys
  # returns the User-settings and the translated description
  def self.setting_keys
    {
      "notify.orderFinished" => I18n.t('model.user.notify.order_finished'),
      "notify.negativeBalance" => I18n.t('model.user.notify.negative_balance'),
      "notify.upcoming_tasks" => I18n.t('model.user.notify.upcoming_tasks'),
      "messages.sendAsEmail" => I18n.t('model.user.notify.send_as_email'),
      "profile.phoneIsPublic" => I18n.t('model.user.notify.phone_is_public'),
      "profile.emailIsPublic" => I18n.t('model.user.notify.email_is_public'),
      "profile.nameIsPublic" => I18n.t('model.user.notify.name_is_public')
    }
  end
  # retuns the default setting for a NEW user
  # for old records nil will returned
  # TODO: integrate default behaviour in acts_as_configurable plugin
  def settings_default(setting)
    # define a default for the settings
    defaults = {
      "messages.sendAsEmail" => true,
      "notify.upcoming_tasks" => true
    }
    return true if self.new_record? && defaults[setting]
  end

  def update_settings
    unless setting_attributes.nil?
      for setting in User::setting_keys.keys
        self.settings[setting] = setting_attributes[setting] && setting_attributes[setting] == '1' ? '1' : nil
      end
    end
  end
  
  def name
    [first_name, last_name].join(" ")
  end

  def receive_email?
    settings['messages.sendAsEmail'] == "1" && email.present?
  end
  
  # Sets the user's password. It will be stored encrypted along with a random salt.
  def set_password
    unless password.blank?
      salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
      self.password_hash, self.password_salt = Digest::SHA1.hexdigest(password + salt), salt
    end
  end
  
  # Returns true if the password argument matches the user's password.
  def has_password(password)
    Digest::SHA1.hexdigest(password + self.password_salt) == self.password_hash
  end
  
  # Returns a random password.
  def new_random_password(size = 3)
    c = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr)
    v = %w(a e i o u y)
    f, r = true, ''
    (size * 2).times do
      r << (f ? c[rand * c.size] : v[rand * v.size])
      f = !f
    end
    r
  end
  
  # Checks the admin role
  def role_admin?
    groups.detect {|group| group.role_admin?}
  end
  
  # Checks the finance role
  def role_finance?
    groups.detect {|group| group.role_finance?}
  end
  
  # Checks the article_meta role
  def role_article_meta?
    groups.detect {|group| group.role_article_meta?}
  end
  
  # Checks the suppliers role
  def role_suppliers?
    groups.detect {|group| group.role_suppliers?}
  end
  
  # Checks the orders role
  def role_orders?
    groups.detect {|group| group.role_orders?}
  end
  
  def ordergroup_name
    ordergroup ? ordergroup.name : I18n.t('model.user.no_ordergroup')
  end

  # returns true if user is a member of a given group
  def member_of?(group)
    group.users.exists?(self.id)
  end
 
  #Returns an array with the users groups (but without the Ordergroups -> because tpye=>"")
  def member_of_groups()
     self.groups.find(:all, :conditions => {:type => ""})
  end

  def self.authenticate(nick, password)
    user = find_by_nick(nick)
    user or user = where('nick LIKE ?', nick)
    if user && user.has_password(password)
      user
    else
      nil
    end
  end

  def token_attributes
    {:id => id, :name => "#{nick} (#{ordergroup.try(:name)})"}
  end

end

