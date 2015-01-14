# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application
namespace :foodsoft do
  desc "Notify users of upcoming tasks"
  task :notify_upcoming_tasks => :environment do
    tasks = Task.where(done: false, due_date: 1.day.from_now.to_date)
    for task in tasks
      rake_say "Send notifications for #{task.name} to .."
      for user in task.users
        begin
          Mailer.upcoming_tasks(user, task).deliver_now if user.settings.notify['upcoming_tasks'] == 1
        rescue
          rake_say "deliver aborted for #{user.email}.."
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
            if user.settings.messages['send_as_email'] == "1" && !user.email.blank?
              begin
                Mailer.not_enough_users_assigned(task, user).deliver_now
              rescue
                rake_say "deliver aborted for #{user.email}"
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
        create_until = Date.today + FoodsoftConfig[:tasks_upfront_days].to_i + 1
        rake_say "creating until #{create_until}"
        while tg.next_task_date.nil? || tg.next_task_date < create_until
          tg.create_next_task
        end
      end
    end
  end
end

# Helper
def rake_say(message)
  puts message unless Rake.application.options.silent
end
