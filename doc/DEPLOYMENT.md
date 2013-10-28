Deployment
=========

Setup
--------

  cp config/deploy.rb.SAMPLE config/deploy.rb
  touch config/deploy/staging.rb
  touch config/deploy/production.rb


Deploy
--------

On your first deploy you should run
  bundle exec cap deploy:setup
  bundle exec cap deploy:check

Deploy to staging
  bundle exec cap deploy

Deploy to production
  bundle exec cap production deploy
