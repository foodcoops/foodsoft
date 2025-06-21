# Use this file to define all tasks, which should be executed by cron
# Learn more: http://github.com/javan/whenever

# Upcoming tasks notifier
every :day, :at => '7:20 am' do
  rake "multicoops:run TASK=foodsoft:notify_upcoming_tasks"
  rake "multicoops:run TASK=foodsoft:notify_users_of_weekly_task"
  rake "multicoops:run TASK=foodsoft:remind_settle"
end

# Weekly taks
every :sunday, :at => '7:14 am' do
  rake "multicoops:run TASK=foodsoft:create_upcoming_periodic_tasks"
end

# Finish ended orders
every 1.minute do
  rake "multicoops:run TASK=foodsoft:finish_ended_orders"
end

# restart everything
every :day, :at => '2:20 am' do
  command '/bin/bash -l -c "/home/foodsoft/restart.sh >> /home/foodsoft/cron-restarts.log"'
end

# charge dues at the start of every month
every 1.month, at: 'start of the month' do
  rake "multicoops:run TASK=foodsoft:ordergroup:charge"
end

# check for nearly full emails
every 5.minutes do
  rake "multicoops:run TASK=foodsoft:ordergroup:nearly_full_email"
end