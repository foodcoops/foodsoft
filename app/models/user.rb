require 'digest/sha1'
# specific user rights through memberships (see Group)
class User < ActiveRecord::Base
  #TODO: acts_as_paraniod ??
  
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_one :ordergroup, :through => :memberships, :source => :group, :class_name => "Ordergroup"
  has_many :workgroups, :through => :memberships, :source => :group, :class_name => "Workgroup"
  has_many :assignments, :dependent => :destroy
  has_many :tasks, :through => :assignments
  has_many :send_messages, :class_name => "Message", :foreign_key => "sender_id"
  has_many :pages, :foreign_key => 'updated_by'
  
  attr_accessor :password, :setting_attributes

  validates_presence_of :nick, :email
  validates_presence_of :password_hash, :message => "Password is required."
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
      "notify.orderFinished" => 'Informier mich über meine Bestellergebnisse (nach Ende der Bestellung).',
      "notify.negativeBalance" => 'Informiere mich, falls meine Bestellgruppe ins Minus rutscht.',
      "notify.upcoming_tasks" => 'Erinnere mich an anstehende Aufgaben.',
      "messages.sendAsEmail" => 'Bekomme Nachrichten als Emails.',
      "profile.phoneIsPublic" => 'Telefon ist für Mitglieder sichtbar',
      "profile.emailIsPublic" => 'E-Mail ist für Mitglieder sichtbar',
      "profile.nameIsPublic" => 'Name ist für Mitglieder sichtbar'
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

  def ordergroup_name
    ordergroup.name if ordergroup
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
    ordergroup ? ordergroup.name : "keine Bestellgruppe"
  end

  # Find all tasks, for which the current user should be responsible
  # but which aren't accepted yet
  def unaccepted_tasks
    # this doesn't work. Produces "undefined method", when later use task.users... Rails Bug?
    # self.tasks.find :all, :conditions => ["accepted = ?", false], :order => "due_date DESC"
    Task.find_by_sql ["SELECT t.* FROM tasks t, assignments a, users u 
                      WHERE u.id = a.user_id
                      AND t.id = a.task_id
                      AND u.id = ?
                      AND a.accepted = ?
                      AND t.done = ?
                      ORDER BY t.due_date ASC", self.id, false, false]
  end
  
  # Find all accepted tasks, which aren't done
  def accepted_tasks
    Task.find_by_sql ["SELECT t.* FROM tasks t, assignments a, users u 
                      WHERE u.id = a.user_id
                      AND t.id = a.task_id
                      AND u.id = ?
                      AND a.accepted = ?
                      AND t.done = ?
                      ORDER BY t.due_date ASC", self.id, true, false]
  end
  
  # find all tasks in the next week (or another number of days)
  def next_tasks(number = 7)
    Task.find_by_sql ["SELECT t.* FROM tasks t, assignments a, users u 
                      WHERE u.id = a.user_id
                      AND t.id = a.task_id
                      AND u.id = ?
                      AND t.due_date >= ?
                      AND t.due_date <= ?
                      AND t.done = ?
                      AND a.accepted = ?
                      ORDER BY t.due_date ASC", self.id, Time.now, number.days.from_now, false, true]  
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
    if user && user.has_password(password)
      user
    else
      nil
    end
  end

end

# == Schema Information
#
# Table name: users
#
#  id                     :integer(4)      not null, primary key
#  nick                   :string(255)     default(""), not null
#  password_hash          :string(255)     default(""), not null
#  password_salt          :string(255)     default(""), not null
#  first_name             :string(255)     default(""), not null
#  last_name              :string(255)     default(""), not null
#  email                  :string(255)     default(""), not null
#  phone                  :string(255)
#  created_on             :datetime        not null
#  reset_password_token   :string(255)
#  reset_password_expires :datetime
#  last_login             :datetime
#

