# encoding: utf-8

require 'digest/sha1'
# specific user rights through memberships (see Group)
class User < ActiveRecord::Base
  include RailsSettings::Extend
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
  has_many :created_orders, :class_name => 'Order', :foreign_key => 'created_by_user_id', :dependent => :nullify
  
  attr_accessor :password, :settings_attributes
  
  # makes the current_user (logged-in-user) available in models
  cattr_accessor :current_user
  
  validates_presence_of :email
  validates_presence_of :password, :on => :create
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :email, :case_sensitive => false
  validates_presence_of :first_name # for simple_form validations
  validates_length_of :first_name, :in => 2..50
  validates_confirmation_of :password
  validates_length_of :password, :in => 5..25, :allow_blank => true
  # allow nick to be nil depending on foodcoop config
  # TODO Rails 4 may have a more beautiful way
  #   http://stackoverflow.com/questions/19845910/conditional-allow-nil-part-of-validation
  validates_length_of :nick, :in => 2..25, :allow_nil => true, :unless => Proc.new { FoodsoftConfig[:use_nick] }
  validates_length_of :nick, :in => 2..25, :allow_nil => false, :if => Proc.new { FoodsoftConfig[:use_nick] }
  validates_uniqueness_of :nick, :case_sensitive => false, :allow_nil => true # allow_nil in length validation

  before_validation :set_password
  after_initialize do
    settings.defaults['profile']  = { 'language' => I18n.default_locale } unless settings.profile
    settings.defaults['messages'] = { 'send_as_email' => true }           unless settings.messages
    settings.defaults['notify']   = { 'upcoming_tasks' => true  }         unless settings.notify
  end
  
  after_save do
    return if settings_attributes.nil?
    settings_attributes.each do |key, value|
      value.each do |k, v|
        case v
          when '1'
            value[k] = true
          when '0' 
            value[k] = false
        end
      end
      self.settings.merge!(key, value)
    end
  end

  # sorted by display name
  def self.natural_order
    # would be sensible to match ApplicationController#show_user
    if FoodsoftConfig[:use_nick]
      order('nick ASC')
    else
      order('first_name ASC, last_name ASC')
    end
  end

  # search by (nick)name
  def self.natural_search(q)
    q = q.strip
    users = User.arel_table
    # full string as nickname
    match_nick = users[:nick].matches("%#{q}%")
    # or each word matches either first or last name
    match_name = q.split.map do |a|
        users[:first_name].matches("%#{a}%").or users[:last_name].matches("%#{a}%")
    end.reduce(:and)
    User.where(match_nick.or match_name)
  end
  
  def locale
    settings.profile['language']
  end
  
  def name
    [first_name, last_name].join(" ")
  end

  def receive_email?
    settings.messages['send_as_email'] && email.present?
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

  def self.authenticate(login, password)
    user = (find_by_nick(login) or find_by_email(login))
    if user && user.has_password(password)
      user
    else
      nil
    end
  end

  # XXX this is view-related; need to move out things like token_attributes
  #     then this can be removed
  def display
    # would be sensible to match ApplicationHelper#show_user
    if FoodsoftConfig[:use_nick]
      nick.nil? ? I18n.t('helpers.application.nick_fallback') : nick
    else
      name
    end
  end

  def token_attributes
    # would be sensible to match ApplicationController#show_user
    #   this should not be part of the model anyway
    {:id => id, :name => "#{display} (#{ordergroup.try(:name)})"}
  end

end

