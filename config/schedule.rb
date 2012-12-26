# Use this file to define all tasks, which should be executed by cron
# Learn more: http://github.com/javan/whenever

# Upcoming tasks notifier
every :day, :at => '7:20 am' do
  rake "multicoops:run foodsoft:notify_upcoming_tasks"
end

# Weekly taks
every :sunday, :at => '7:14 am' do
  rake "multicoops:run foodsoft:create_upcoming_weekly_tasks"
  rake "multicoops:run foodsoft:notify_users_of_weekly_task"
end


