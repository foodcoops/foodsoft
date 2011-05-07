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


# == Schema Information
#
# Table name: assignments
#
#  id       :integer(4)      not null, primary key
#  user_id  :integer(4)      default(0), not null
#  task_id  :integer(4)      default(0), not null
#  accepted :boolean(1)      default(FALSE)
#

