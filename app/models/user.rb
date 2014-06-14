# encoding: utf-8

require 'digest/sha1'
# specific user rights through memberships (see Group)
class User < ActiveRecord::Base
  include RailsSettings::Extend
  #TODO: acts_as_paraniod ??

  # @!attribute memberships
  #   @return [Array<Membership>]
  has_many :memberships, :dependent => :destroy
  # @!attribute groups
  #   @return [Array<Group>]
  has_many :groups, :through => :memberships
  # @!attribute workgroups
  #   @return [Array<Workgroup>]
  has_many :workgroups, :through => :memberships, :source => :group, :class_name => "Workgroup"
  # @!attribute assignments
  #   @return [Array<Assignment>]
  has_many :assignments, :dependent => :destroy
  # @!attribute tasks
  #   @return [Array<Task>]
  has_many :tasks, :through => :assignments
  # @!attribute send_messages
  #   @return [Array<Message>] Messages sent by user
  #   @todo Rename to +sent_messages+ (proper English)
  #   @todo Move to messages plugin
  has_many :send_messages, :class_name => "Message", :foreign_key => "sender_id"
  # @!attribute created_orders
  #   @return [Array<Order>] Orders created by user.
  has_many :created_orders, :class_name => 'Order', :foreign_key => 'created_by_user_id', :dependent => :nullify

  # @!attribute ordergroup
  #   @return [Ordergroup] The ordergroup of this member.
  #   @see #ordergroup=
  def ordergroup
    # An alternative option would be to use
    #   has_one :membership
    #   has_one :ordergroup, :through => :membership, :source => :group, :class_name => "Ordergroup"
    # (note that +has_one+ cannot work through a +has_many+ relation) but this caused some tests to fail.
    groups.where(:type => 'Ordergroup').first
  end

  # @!attribute password
  #   This is not populated from the database, only used to set a new password.
  #   @return [String] New password to be stored.
  attr_accessor :password
  # @!attribute settings_attributes
  #   New settings to be stored.
  #   Values +'0'+ and +'1'+ will be converted to booleans first.
  #   @return [Hash{String => String}] New settings to be stored.
  attr_accessor :settings_attributes

  # @!attribute current_user
  #   Makes the current_user (logged-in-user) available in models.
  #   @return [User] Current logged-in user
  cattr_accessor :current_user

  validates_presence_of :email
  validates_presence_of :password, :on => :create
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
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
     self.groups.where(type: '')
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

  # for nested form with ordergroup
  def ordergroup=(attributes)
    if attributes[:id].blank? or attributes[:id] == 'new'
      # dissociate the existing ordergroup
      #   deleting the association doesn't work, as it sets the association's group to zero
      ordergroup.user_ids = ordergroup.user_ids.reject {|i| i==self.id} if ordergroup
      return if attributes[:id].blank?
    end
    if attributes[:id] == 'new'
      # create a new ordergroup (this already makes the association)
      Ordergroup.build_from_user(self, attributes.reject {|i| i=='id'})
    elsif ordergroup.nil?
      # create a new relation
      memberships << Membership.new(group_id: attributes[:id])
    elsif attributes[:id] != ordergroup.id
      # update relation
      ordergroup.memberships.first.update_attributes(group_id: attributes[:id])
    end
  end

end

