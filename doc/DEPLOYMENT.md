Deployment
=========

Setup
-----

1. Initialise your [Capistrano](http://capistranorb.com/) setup

      ```sh
      bundle exec cap install
      sed -i 's|^# \(require.*rails.*\)|\1|' Capfile
      cp config/deploy.rb.SAMPLE config/deploy.rb
      ```

   When you're using [RVM](http://rvm.io/) on the server you may want to
   uncomment the corresponding line in `Capfile`.

2. Adapt your configuration in `config/deploy.rb` and `config/deploy/*.rb`


Deploy
------

On your first deploy you should run (choose either staging or production)

    bundle exec cap staging deploy:check

This will fail, which is ok, because there is no configuration yet. On your
server, there is a directory `shared/config` for each installation, which
contains the configuration. Create `database.yml`, `app_config.yml` and
`initializers/secret_token.rb` and try again.
(See `lib/capistrano/tasks/deploy_initial.cap` for a way to automate this.)

Deploy to staging

    bundle exec cap staging deploy

Deploy to production

    bundle exec cap production deploy

