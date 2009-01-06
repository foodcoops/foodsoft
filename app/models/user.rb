require 'digest/sha1'

# A foodsoft user.
# 
# * memberships
# * groups
# * first_name, last_name, email, phone, address
# * nick
# * password (stored as a hash)
# * settings (user properties via acts_as_configurable plugin)
# specific user rights through memberships (see Group)
class User < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_many :order_groups, :through => :memberships, :source => :group
  has_many :assignments, :dependent => :destroy
  has_many :tasks, :through => :assignments
  
  attr_accessible :nick, :first_name, :last_name, :email, :phone, :address
	
  validates_length_of :nick, :in => 2..25
  validates_uniqueness_of :nick
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :email	
  validates_length_of :first_name, :in => 2..50

  # Adds support for configuration settings (through "settings" attribute).
  acts_as_configurable
  
  # makes the current_user (logged-in-user) available in models
  cattr_accessor :current_user
  
  # User settings keys
  # returns the User-settings and the translated description
  def self.setting_keys
    settings_hash = {
      "notify.orderFinished" => _('Get message with order result'),
      "notify.negativeBalance" => _('Get message if negative account balance'),
      "messages.sendAsEmail" => _('Get messages as emails'),
      "profile.phoneIsPublic" => _('Phone is visible for foodcoop members'),
      "profile.emailIsPublic" => _('Email is visible for foodcoop members'),
      "profile.nameIsPublic" => _('Name is visible for foodcoop members')
    }
    return settings_hash
  end
  # retuns the default setting for a NEW user
  # for old records nil will returned
  # TODO: integrate default behaviour in acts_as_configurable plugin
  def settings_default(setting)
    # define a default for the settings
    defaults = {
      "messages.sendAsEmail" => true
    }
    return true if self.new_record? && defaults[setting]
  end
  
  
  # Sets the user's password. It will be stored encrypted along with a random salt.
  def password=(password)
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.password_hash, self.password_salt = Digest::SHA1.hexdigest(password + salt), salt
  end
  
  # Returns true if the password argument matches the user's password.
  def has_password(password)
    Digest::SHA1.hexdigest(password + self.password_salt) == self.password_hash
  end
  
  #Sets the passwort, and if fails it returns error-messages (see above)
  def set_password(options = {:required => false}, password = nil, confirmation = nil)
    required = options[:required]
    if required && (password.nil? || password.empty?) 
      self.errors.add_to_base _('Password is required')
    elsif !password.nil? && !password.empty?
      if password != confirmation
        self.errors.add_to_base _("Passwords doesn't match")
      elsif password.length < 5 || password.length > 25
        self.errors.add_to_base _('Password-length has to be between 5 and 25 characters')
      else 
        self.password = password
      end
    end  
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
  
  # Returns the user's OrderGroup or nil if none found.
  def find_ordergroup
    order_groups.first
    #groups.find(:first, :conditions => "type = 'OrderGroup'")
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
  def is_member_of(group)
    return true if group.users.detect {|user| user == self}
  end
 
  #Returns an array with the users groups (but without the OrderGroups -> because tpye=>"")
  def member_of_groups()
     self.groups.find(:all, :conditions => {:type => ""})
  end

end