# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application
namespace :foodsoft do
  desc "Notify users of upcoming tasks"
  task :notify_upcoming_tasks => :environment do
    tasks = Task.where(done: false, due_date: 1.day.from_now.to_date)
    for task in tasks
      rake_say "Send notifications for #{task.name} to .."
      for user in task.users
        if user.settings.notify['upcoming_tasks']
          Mailer.deliver_now_with_user_locale user do
            Mailer.upcoming_tasks(user, task)
          end
        end
      end
    end
  end

  desc "Notify workgroup of upcoming weekly task"
  task :notify_users_of_weekly_task => :environment do
    tasks = Task.where(done: false, due_date: 7.day.from_now.to_date)
    for task in tasks
      unless task.enough_users_assigned?
        workgroup = task.workgroup
        if workgroup
          rake_say "Notify workgroup: #{workgroup.name} for task #{task.name}"
          for user in workgroup.users
            if user.receive_email?
              Mailer.deliver_now_with_user_locale user do
                Mailer.not_enough_users_assigned(task, user)
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
      created_until = tg.create_tasks_for_upfront_days
      rake_say "created until #{created_until}"
    end
  end
end

# Helper
def rake_say(message)
  puts message unless Rake.application.options.silent
end
