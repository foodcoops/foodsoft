# encoding: utf-8
class Workgroup < Group
  
  has_many :tasks
  # returns all non-finished tasks
  has_many :open_tasks, :class_name => 'Task', :conditions => ['done = ?', false], :order => 'due_date ASC'

  validates_uniqueness_of :name
  validates_presence_of :task_name, :weekday, :task_required_users, :next_weekly_tasks_number,
                        :if => :weekly_task
  validates_numericality_of :next_weekly_tasks_number, :greater_than => 0, :less_than => 21, :only_integer => true,
                            :if => :weekly_task
  validates_length_of :task_description, maximum: 250
  validate :last_admin_on_earth, :on => :update
  before_destroy :check_last_admin_group

  def self.weekdays
    [["Montag", "1"], ["Dienstag", "2"], ["Mittwoch","3"],["Donnerstag","4"],["Freitag","5"],["Samstag","6"],["Sonntag","0"]]
  end

  # Returns an Array with date-objects to represent the next weekly-tasks
  def next_weekly_tasks
    # our system starts from 0 (sunday) to 6 (saturday)
    # get difference between groups weekday and now
    diff = self.weekday - Time.now.wday 
    if diff >= 0  
      # weektask is in current week
      nextTask = diff.day.from_now
    else
      # weektask is in the next week
      nextTask = (diff + 7).day.from_now
    end
    # now generate the Array
    nextTasks = Array.new
    next_weekly_tasks_number.times do
      nextTasks << nextTask.to_date
      nextTask = 1.week.from_now(nextTask)
    end
    return nextTasks
  end

  def task_attributes(date)
    {
        :name => task_name,
        :description => task_description,
        :due_date => date,
        :required_users => task_required_users,
        :duration => task_duration,
        :weekly => true
    }
  end

  protected

  # Check before destroy a group, if this is the last group with admin role
  def check_last_admin_group
    if role_admin && Workgroup.where(:role_admin => true).size == 1
      raise "Die letzte Gruppe mit Admin-Rechten darf nicht gelöscht werden"
    end
  end

  # add validation check on update
  # Return an error if this is the last group with admin role and role_admin should set to false
  def last_admin_on_earth
    if !role_admin && !Workgroup.where('role_admin = ? AND id != ?', true, id).exists?
      errors.add(:role_admin, "Der letzten Gruppe mit Admin-Rechten darf die Admin-Rolle nicht entzogen werden")
    end
  end
  
end

