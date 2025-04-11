web: bundle exec rails server --binding=0.0.0.0 --port=$PORT
worker: QUEUE=* bundle exec rake resque:work
mail: bundle exec rake foodsoft:reply_email_smtp_server
cron: supercronic crontab
