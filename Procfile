web: bundle exec rails server thin --binding=0.0.0.0 --port=$PORT
worker: QUEUE=foodsoft_notifier bundle exec rake resque:work
mail: bundle exec rake foodsoft:reply_email_smtp_server
cron: supercronic crontab
