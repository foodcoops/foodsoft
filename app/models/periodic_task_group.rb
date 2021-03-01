class PeriodicTaskGroup < ApplicationRecord
  has_many :tasks, dependent: :destroy

  def has_next_task?
    return false if tasks.empty?
    return false if tasks.first.due_date.nil?

    return true
  end

  def create_next_task
    template_task = tasks.first
    self.next_task_date ||= template_task.due_date + period_days

    next_task = template_task.dup
    next_task.due_date = next_task_date
    next_task.done = false
    next_task.save

    self.next_task_date += period_days
    self.save
  end

  def create_tasks_until(create_until)
    if has_next_task?
      while next_task_date.nil? || next_task_date < create_until
        create_next_task
      end
    end
  end

  def create_tasks_for_upfront_days
    create_until = Date.today + FoodsoftConfig[:tasks_upfront_days].to_i + 1
    create_tasks_until create_until
    create_until
  end

  def exclude_tasks_before(task)
    tasks.where("due_date < '#{task.due_date}'").each do |t|
      t.update_attribute(:periodic_task_group, nil)
    end
  end

  def update_tasks_including(template_task, prev_due_date)
    group_tasks = tasks + [template_task]
    due_date_delta = template_task.due_date - prev_due_date
    tasks.each do |task|
      task.update!(name: template_task.name,
                   description: template_task.description,
                   duration: template_task.duration,
                   required_users: template_task.required_users,
                   workgroup: template_task.workgroup,
                   due_date: task.due_date + due_date_delta)
    end
    group_tasks.each do |task|
      task.update_columns(periodic_task_group_id: self.id)
    end
  end

  protected

  # @return [Number] Number of days between two periodic tasks
  def period_days
    # minimum of one to avoid inifite loop when value is invalid
    [FoodsoftConfig[:tasks_period_days].to_i, 1].max
  end
end
