# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application

namespace :foodsoft do
  desc "Notify users of upcoming tasks"
  task :notify_upcoming_tasks => :environment do
    tasks = Task.where(done: false, due_date: 1.day.from_now.to_date)
    for task in tasks
      puts "Send notifications for #{task.name} to .."
      for user in task.users
        begin
          Mailer.upcoming_tasks(user, task).deliver if user.settings['notify.upcoming_tasks'] == 1
        rescue
          puts "deliver aborted for #{user.email}.."
        end
      end
    end
  end

  desc "Create upcoming workgroups tasks (next 3 to 7 weeks)"
  task :create_upcoming_weekly_tasks => :environment do
    workgroups = Workgroup.where(weekly_task: true)
    for workgroup in workgroups
      puts "Create weekly tasks for #{workgroup.name}"
      workgroup.next_weekly_tasks[3..5].each do |date|
        unless workgroup.tasks.exists?({:due_date => date, :weekly => true})
          workgroup.tasks.create(workgroup.task_attributes(date))
        end
      end
    end
  end

  desc "Notify workgroup of upcoming weekly task"
  task :notify_users_of_weekly_task => :environment do
    for workgroup in Workgroup.all
      for task in workgroup.tasks.where(due_date: 7.days.from_now.to_date)
        unless task.enough_users_assigned?
          puts "Notify workgroup: #{workgroup.name} for task #{task.name}"
          for user in workgroup.users
            if user.settings['messages.sendAsEmail'] == "1" && !user.email.blank?
              begin
                Mailer.not_enough_users_assigned(task, user).deliver
              rescue
                puts "deliver aborted for #{user.email}"
              end
            end
          end
        end
      end
    end
  end

  desc "Create upcoming periodic tasks"
  task :create_upcoming_periodic_tasks => :environment do
    for tg in PeriodicTaskGroup.all
      if tg.has_next_task?
        while tg.next_task_date.nil? or tg.next_task_date < Date.today + 30
          tg.create_next_task
        end
      end
    end
  end
end
