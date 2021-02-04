class MoveWeeklyTasks < ActiveRecord::Migration[4.2]
  def up
    Workgroup.where(weekly_task: true).each do |workgroup|
      task_group = PeriodicTaskGroup.create
      puts "Moving weekly task for workgroup #{workgroup.name} to group #{task_group.id}"
      workgroup.tasks.undone.each do |task|
        task.update_column(:periodic_task_group_id, task_group.id) if weekly_task?(workgroup, task)
      end
      tasks = task_group.tasks.order(:due_date)
      task_group.next_task_date = tasks.last.due_date + PeriodicTaskGroup::PeriodDays unless tasks.empty?
      task_group.save!
      puts "Associated #{tasks.count} tasks with group and set next_task_date to #{task_group.next_task_date}"
    end
  end

  def down
    PeriodicTaskGroup.all.each do |task_group|
      unless task_group.tasks.empty?
        task = task_group.tasks.first
        workgroup = task.workgroup
        puts "Writing task data of group #{task_group.id} to workgroup #{workgroup.name}"
        workgroup_attributes = {
          weekly_task: true,
          weekday: task.due_date.days_to_week_start(:sunday),
          task_name: task.name,
          task_description: task.description,
          task_required_users: task.required_users,
          task_duration: task.duration
        }
        workgroup.update_attributes workgroup_attributes
        task_group.tasks.update_all weekly: true
      end
    end
  end

private
  def weekly_task?(workgroup, task)
    return false if task.due_date.nil?

    group_task = {
      weekday: workgroup.weekday,
      name: workgroup.task_name,
      description: workgroup.task_description,
      required_users: workgroup.task_required_users,
      duration: workgroup.task_duration,
      weekly: true,
      done: false,
      workgroup_id: workgroup.id
    }
    task_task = {
      weekday: task.due_date.days_to_week_start(:sunday),
      name: task.name,
      description: task.description,
      required_users: task.required_users,
      duration: task.duration,
      weekly: task.weekly,
      done: task.done,
      workgroup_id: task.workgroup_id
    }
    group_task == task_task
  end
end
