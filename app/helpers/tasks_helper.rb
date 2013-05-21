module TasksHelper

  def task_assignments(task)
    task.assignments.map do |ass|
      content_tag :span, ass.user.nick, :class => (ass.accepted? ? 'accepted' : 'unaccepted')
    end.join(", ").html_safe
  end

  # generate colored number of still required users
  def highlighted_required_users(task)
    unless task.enough_users_assigned?
      content_tag :span, task.still_required_users, class: 'badge badge-important',
                  title: I18n.t('helpers.tasks.required_users', :count => task.still_required_users)
    end
  end
end
