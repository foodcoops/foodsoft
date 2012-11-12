class Task < ActiveRecord::Base
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments
  belongs_to :workgroup

  scope :non_group, where(workgroup_id: nil, done: false)
  scope :done, where(done: true)
  scope :undone, where(done: false)

  attr_accessor :current_user_id

  # form will send user in string. responsibilities will added later
  attr_protected :users

  validates :name, :presence => true, :length => { :minimum => 3 }
  validates :required_users, :presence => true
  validates_numericality_of :duration, :required_users, :only_integer => true, :greater_than => 0
  validates_length_of :description, maximum: 250

  after_save :update_ordergroup_stats

  # Find all tasks, for which the current user should be responsible
  # but which aren't accepted yet
  def self.unaccepted_tasks_for(user)
    user.tasks.undone.where(assignments: {accepted: false})
  end

  # Find all accepted tasks, which aren't done
  def self.accepted_tasks_for(user)
    user.tasks.undone.where(assignments: {accepted: true})
  end


  # find all tasks in the next week (or another number of days)
  def self.next_assigned_tasks_for(user, number = 7)
    user.tasks.undone.where(assignments: {accepted: true}).
        where(["tasks.due_date >= ? AND tasks.due_date <= ?", Time.now, number.days.from_now])
  end

  # count tasks with no responsible person
  # tasks for groups the user is not a member are ignored
  def self.unassigned_tasks_for(user)
    Task.undone.where(assigned: false).includes(:workgroup).all.select do |task|
      !task.workgroup or user.member_of?(task.workgroup)
    end
  end

  def is_assigned?(user)
    self.assignments.detect {|ass| ass.user_id == user.id }
  end
  
  def is_accepted?(user)
    self.assignments.detect {|ass| ass.user_id == user.id && ass.accepted }
  end
  
  def enough_users_assigned?
    assignments.find_all_by_accepted(true).size >= required_users ? true : false
  end

  # Get users from comma seperated ids
  # and makes the users responsible for the task
  def user_list=(ids)
    list = ids.split(",")
    new_users = list - users.collect(&:id)
    old_users = users.reject { |user| list.include?(user.id) }
    
    logger.debug "[debug] New users: #{new_users}"
    logger.debug "Old users: #{old_users}"
    
    self.class.transaction do
      # delete old assignments
      if old_users.any?
        assignments.where(user_id: old_users.map(&:id)).each(&:destroy)
      end
      # create new assignments
      new_users.each do |id|
        user = User.find(id)
        if user.blank?
          errors.add(:user_list)
        else
          if  id == current_user_id
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
    @user_list ||= users.collect(&:id).join(", ")
  end

  private

  def update_ordergroup_stats
    if done
      users.each { |u| u.ordergroup.update_stats! if u.ordergroup }
    end
  end
end

