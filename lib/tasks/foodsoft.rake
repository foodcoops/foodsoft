# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application
namespace :foodsoft do
  desc "Finish ended orders"
  task :finish_ended_orders => :environment do
    Order.finish_ended!
  end

  desc "Reminder to settle orders"
  task :remind_settle => :environment do
    Order.email_reminder_to_settle
  end

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

  desc "Report on fees paid"
  task :report_fees => :environment do
    total_fees = 0
    Ordergroup.order(:name).each do |ordergroup|
      user_emails = ordergroup.users.map(&:email).join(', ')
      keywords = ['dues', 'monthly', 'fee']
      sum = ordergroup.financial_transactions.where("note not like ? and (note LIKE ? or note like ?)", "%Order:%", "%dues%", "%fees%").sum(:amount)
      if sum <= -100
        puts "#{ordergroup.id},#{ordergroup.name},#{sum}, #{user_emails}"
        total_fees += sum
        # end
        # transactions_by_year = ordergroup.financial_transactions
        #                                  .where("note LIKE ?", "%dues%")
        #                                  .group_by { |t| t.created_on.year }
        #                                  .sort
        #
        # transactions_by_year.each do |year, transactions|
        #   sum = transactions.sum(&:amount)
        #   puts "#{ordergroup.name},#{year},#{sum}, #{user_emails}"
        #   total_fees += sum
      end
    end
    puts "total fees #{total_fees}"
  end

  namespace :ordergroup do
    desc "Charges each Ordergroup $5 at the start of each month, excluding certain groups"
    task dues: :environment do
      excludes = ['ZZZ', 'Leaving', 'Z - Group']
      Ordergroup.undeleted.find_each do |ordergroup|
        next if excludes.any? { |ex| ordergroup.name.start_with?(ex) }
        due_note = "Monthly dues for #{Date.today.strftime('%B %Y')}"
        puts "adding -5 charge for #{ordergroup.name} : #{due_note}"
        ordergroup.financial_transactions.create(amount: -5, note: due_note)
      end
    end
  end

  namespace :ordergroup do
    desc "Sends an email on partially full cases"
    task nearly_full_email: :environment do

      orders1 = Order.where(ends: ((Time.now)...(Time.now + 18.hours)))
                      .select{|o| !FoodsoftCache.get("nearly_full-18-hour-#{o.id}")}
      orders2 = Order.where(ends: ((Time.now)...(Time.now + 2.hours )))
                   .select{|o| !FoodsoftCache.get("nearly_full-2-hour-#{o.id}")}

      # mark them so we don't resend the message
      orders1.each{ |o| FoodsoftCache.set("nearly_full-18-hour-#{o.id}", true)}
      orders2.each{ |o| FoodsoftCache.set("nearly_full-2-hour-#{o.id}", true)}

      orders = orders1 + orders2
      # orders = [Order.find(874)]
      puts "checking #{orders.count} orders for nearly full articles"
      orders.each do |order|
        excludes = ['ZZZ', 'Leaving', 'Z - Group']
        if order.nearly_full_order_articles.count > 0
          Ordergroup.undeleted.find_each do |ordergroup|
            next if excludes.any? { |ex| ordergroup.name.start_with?(ex) }
            ordergroup.users.each do |user|
              puts "mailing #{user.email} about #{order.supplier.name} #{order.note}"
              Mailer.nearly_full_articles_email(order, user)
                    .deliver_now
            end
          end
        else
          puts "no nearly full articles"
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

  desc "Parse incoming email on stdin (options: RECIPIENT=foodcoop.handling)"
  task :parse_reply_email => :environment do
    FoodsoftMailReceiver.received ENV['RECIPIENT'], STDIN.read
  end

  desc "Start STMP server for incoming email (options: SMTP_SERVER_PORT=2525, SMTP_SERVER_HOST=0.0.0.0)"
  task :reply_email_smtp_server => :environment do
    port = ENV['SMTP_SERVER_PORT'].present? ? ENV['SMTP_SERVER_PORT'].to_i : 2525
    host = ENV['SMTP_SERVER_HOST']
    rake_say "Started SMTP server for incoming email on port #{port}."
    server = FoodsoftMailReceiver.new port, host, 1, logger: Rails.logger
    server.start
    server.join
  end
end

# Helper
def rake_say(message)
  puts message unless Rake.application.options.silent
end
