# == Schema Information
#
# Table name: tasks
#
#  id             :integer         not null, primary key
#  name           :string(255)     default(""), not null
#  description    :string(255)
#  due_date       :date
#  done           :boolean
#  workgroup_id   :integer
#  assigned       :boolean
#  created_on     :datetime        not null
#  updated_on     :datetime        not null
#  required_users :integer         default(1)
#

class Task < ActiveRecord::Base
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments
  belongs_to :workgroup

  named_scope :non_group, :conditions => { :workgroup_id => nil, :done => false }
  named_scope :done, :conditions => {:done => true}, :order => "due_date DESC"
  named_scope :upcoming, lambda { |*args| {:conditions => ["done = 0 AND due_date = ?", (args.first || 7.days.from_now)]} }
  
  # form will send user in string. responsibilities will added later
  attr_protected :users
  
  validates_length_of :name, :minimum => 3

  after_save :update_ordergroup_stats
  
  def is_assigned?(user)
    self.assignments.detect {|ass| ass.user_id == user.id }
  end
  
  def is_accepted?(user)
    self.assignments.detect {|ass| ass.user_id == user.id && ass.accepted }
  end
  
  def enough_users_assigned?
    assignments.find_all_by_accepted(true).size >= required_users ? true : false
  end
  
  # extracts nicknames from a comma seperated string 
  # and makes the users responsible for the task
  def user_list=(string)
    @user_list = string.split(%r{,\s*})
    new_users = @user_list - users.collect(&:nick)
    old_users = users.reject { |user| @user_list.include?(user.nick) }
    
    logger.debug "New users: #{new_users}"
    logger.debug "Old users: #{old_users}"
    
    self.class.transaction do
      # delete old assignments
      if old_users.any?
        assignments.find(:all, :conditions => ["user_id IN (?)", old_users.collect(&:id)]).each(&:destroy)
      end
      # create new assignments
      new_users.each do |nick|
        user = User.find_by_nick(nick)
        if user.blank?
          errors.add(:user_list)
        else
          if  user == User.current_user
            # current_user will accept, when he puts himself to the list of users
            self.assignments.build :user => user, :accepted => true
          else
            # normal assignement
            self.assignments.build :user => user
          end
        end
      end
    end
  end
  
  def user_list
    @user_list ||= users.collect(&:nick).join(", ")
  end

  private

  def update_ordergroup_stats
    if done
      users.each { |u| u.ordergroup.update_stats! }
    end
  end
end
