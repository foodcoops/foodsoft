module TasksHelper

  def task_assignments(task)
    task.assignments.map do |ass|
      content_tag :span, ass.user.nick, :class => (ass.accepted? ? 'accepted' : 'unaccepted')
    end.join(", ").html_safe
  end

  # generate colored number of still required users
  def highlighted_required_users(task)
    unless task.enough_users_assigned?
      still_required = task.required_users - task.assignments.select { |ass| ass.accepted }.size
      content_tag :span, still_required, class: 'badge badge-important',
                  title: "Es fehlen #{still_required} Mitstreiterinnen!"
    end
  end
end
