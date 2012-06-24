# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application

namespace :foodsoft do
  desc "Notify users of upcoming tasks"
  task :notify_upcoming_tasks => :environment do
    tasks = Task.find :all, :conditions => ["done = ? AND due_date = ?", false, 1.day.from_now.to_date]
    for task in tasks
      puts "Send notifications for #{task.name} to .."
      for user in task.users
        if user.settings['notify.upcoming_tasks'] == 1
          begin
            puts "#{user.email}.."
            Mailer.upcoming_tasks(user, task).deliver
          rescue
            puts "deliver aborted for #{user.email}.."
          end
        end
      end
    end
  end

  desc "Create upcoming workgroups tasks (next 3 to 7 weeks)"
  task :create_upcoming_weekly_tasks => :environment do
    workgroups = Workgroup.all :conditions => {:weekly_task => true}
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
      for task in workgroup.tasks.all(:conditions => ["due_date = ?", 7.days.from_now.to_date])
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

  desc "finished order tasks, cleanup, notifications, stats ..."
  task :finished_order_tasks => :environment do
    puts "Start: #{Time.now}"
    order = Order.find(ENV["ORDER_ID"])

    # Update GroupOrder prices
    order.group_orders.each { |go| go.update_price! }

    # Clean up
    # Delete no longer required order-history (group_order_article_quantities) and
    # TODO: Do we need articles, which aren't ordered? (units_to_order == 0 ?)
    order.order_articles.each do |oa|
      oa.group_order_articles.each { |goa| goa.group_order_article_quantities.clear }
    end

    # Notifications
    for group_order in order.group_orders
      for user in group_order.ordergroup.users
        begin
          Mailer.order_result(user, group_order).deliver if user.settings["notify.orderFinished"] == '1'
        rescue
          puts "deliver aborted for #{user.email}.."
        end
      end
    end

    # Stats
    order.ordergroups.each { |o| o.update_stats! }

    puts "End: #{Time.now}"
  end
end
