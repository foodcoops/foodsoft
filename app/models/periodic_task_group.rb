class PeriodicTaskGroup < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy

  PeriodDays = 7
  
  def has_next_task?
    return false if self.tasks.empty?
    return false if self.tasks.first.due_date.nil?
    return true
  end

  def create_next_task
    template_task = self.tasks.first
    self.next_task_date ||= template_task.due_date + PeriodDays
    
    next_task = template_task.dup
    next_task.due_date = self.next_task_date    
    next_task.save

    self.next_task_date += PeriodDays
    self.save
  end
end
