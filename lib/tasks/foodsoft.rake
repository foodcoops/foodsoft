# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application
namespace :foodsoft do
  desc 'Finish ended orders'
  task finish_ended_orders: :environment do
    Order.finish_ended!
  end

  desc 'Notify users of upcoming tasks'
  task notify_upcoming_tasks: :environment do
    tasks = Task.where(done: false, due_date: 1.day.from_now.to_date)
    for task in tasks
      rake_say "Send notifications for #{task.name} to .."
      for user in task.users
        next unless user.settings.notify['upcoming_tasks']

        Mailer.deliver_now_with_user_locale user do
          Mailer.upcoming_tasks(user, task)
        end
      end
    end
  end

  desc 'Notify workgroup of upcoming weekly task'
  task notify_users_of_weekly_task: :environment do
    tasks = Task.where(done: false, due_date: 7.days.from_now.to_date)
    for task in tasks
      next if task.enough_users_assigned?

      workgroup = task.workgroup
      next unless workgroup

      rake_say "Notify workgroup: #{workgroup.name} for task #{task.name}"
      for user in workgroup.users
        next unless user.receive_email?

        Mailer.deliver_now_with_user_locale user do
          Mailer.not_enough_users_assigned(task, user)
        end
      end
    end
  end

  desc 'Create upcoming periodic tasks'
  task create_upcoming_periodic_tasks: :environment do
    for tg in PeriodicTaskGroup.all
      created_until = tg.create_tasks_for_upfront_days
      rake_say "created until #{created_until}"
    end
  end

  desc 'Parse incoming email on stdin (options: RECIPIENT=foodcoop.handling)'
  task parse_reply_email: :environment do
    FoodsoftMailReceiver.received ENV.fetch('RECIPIENT', nil), STDIN.read
  end

  desc 'Start STMP server for incoming email (options: SMTP_SERVER_PORT=2525, SMTP_SERVER_HOST=0.0.0.0)'
  task reply_email_smtp_server: :environment do
    port = ENV['SMTP_SERVER_PORT'].present? ? ENV['SMTP_SERVER_PORT'].to_i : 2525
    host = ENV.fetch('SMTP_SERVER_HOST', nil)
    rake_say "Started SMTP server for incoming email on port #{port}."
    server = FoodsoftMailReceiver.new(ports: port, hosts: host, max_processings: 1, logger: Rails.logger)
    server.start
    server.join
  end

  desc 'Import and assign bank transactions'
  task import_and_assign_bank_transactions: :environment do
    BankAccount.find_each do |ba|
      importer = ba.find_connector
      next unless importer

      importer.load nil
      ok = importer.import nil
      next unless ok

      importer.finish
      assign_count = ba.assign_unlinked_transactions
      rake_say "#{ba.name}: imported #{importer.count}, assigned #{assign_count}"
    end
  end

  desc 'Prune attachments older than maximum age'
  task prune_old_attachments: :environment do
    if FoodsoftConfig[:attachment_retention_days]
      rake_say "Pruning attachments older than #{FoodsoftConfig[:attachment_retention_days]} days"
      ActiveStorage::Attachment.where('created_at < ?',
                                      FoodsoftConfig[:attachment_retention_days].days.ago).each do |attachment|
        rake_say attachment.inspect
        attachment.purge_later
      end
    else
      rake_say "Please configure your app_config.yml accordingly:\nattachment_retention_days: <number of days>"
    end
  end
end

# Helper
def rake_say(message)
  puts message unless Rake.application.options.silent
end
