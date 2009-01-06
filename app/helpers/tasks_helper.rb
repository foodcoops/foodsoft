module TasksHelper
  
  # generate colored number of still required users
  def highlighted_required_users(task)
    unless task.enough_users_assigned?
      still_required = task.required_users - task.assignments.select { |ass| ass.accepted }.size
      "<small style='color:red;font-weight:bold'>(#{still_required})</small>"
    end
  end
end
