class Assignment < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :task
  
  # after user is assigned mark task as assigned
  def after_create
      self.task.update_attribute(:assigned, true)
  end
  
  # update assigned-attribute
  def after_destroy
    self.task.update_attribute(:assigned, false) if self.task.assignments.empty?
  end
end


