class Workgroup < Group
  
  has_many :tasks
  # returns all non-finished tasks
  has_many :open_tasks, :class_name => 'Task', :conditions => ['done = ?', false], :order => 'due_date ASC'

  validates_presence_of :task_name, :weekday, :task_required_users,
    :if => Proc.new {|workgroup| workgroup.weekly_task }

  def self.weekdays
    [["Montag", "1"], ["Dienstag", "2"], ["Mittwoch","3"],["Donnerstag","4"],["Freitag","5"],["Samstag","6"],["Sonntag","0"]]
  end

  # Returns an Array with date-objects to represent the next weekly-tasks
  def next_weekly_tasks(number = 8)
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
    number.times do
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
      :weekly => true
    }
  end
  
end

# == Schema Information
#
# Table name: groups
#
#  id                  :integer         not null, primary key
#  type                :string(255)     default(""), not null
#  name                :string(255)     default(""), not null
#  description         :string(255)
#  account_balance     :decimal(8, 2)   default(0.0), not null
#  account_updated     :datetime
#  created_on          :datetime        not null
#  role_admin          :boolean         default(FALSE), not null
#  role_suppliers      :boolean         default(FALSE), not null
#  role_article_meta   :boolean         default(FALSE), not null
#  role_finance        :boolean         default(FALSE), not null
#  role_orders         :boolean         default(FALSE), not null
#  weekly_task         :boolean         default(FALSE)
#  weekday             :integer
#  task_name           :string(255)
#  task_description    :string(255)
#  task_required_users :integer         default(1)
#  deleted_at          :datetime
#  contact_person      :string(255)
#  contact_phone       :string(255)
#  contact_address     :string(255)
#  stats               :text
#

