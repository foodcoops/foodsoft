# Deployment

The recommended way to run Foodsoft in production is using docker. Alternative options are
discussed [in the wiki](https://github.com/foodcoops/foodsoft/wiki/Deployment-notes). If you
have any questions, please have a look at the [forum](https://forum.foodsoft.net).

## Docker

_This section is a work in progress._

### Build

You can use the [official production docker image](https://hub.docker.com/r/foodcoops/foodsoft/).
If you want to build the image yourself instead, run:

    docker build --tag foodsoft:latest --rm .

### Run (basic)

You'll need to set at least the following environment variables:

* `SECRET_KEY_BASE` - random string of 30+ characters, try `rake secret`
* `DATABASE_URL` - pointing to your MySQL installation (`mysql2://user:pass@mysql.host/foodsoftdb?encoding=utf8`)
* `REDIS_URL` - pointing to your Redis instance (`redis://redis.host:6379`)

You'll also need to supply the Foodsoft configuration file, for example by
mounting it as a volume. Copy `config/app_config.yml.SAMPLE` to `config/app_config.yml`
and customize the settings.

Then run the webserver, exposing port 3000 on the current host:

    docker run --name foodsoft_web -p 3000 \
      -e SECRET_KEY_BASE -e DATABASE_URL -e REDIS_URL -e RAILS_FORCE_SSL=false \
      -v `pwd`/config/app_config.yml:/usr/src/app/config/app_config.yml:ro \
      foodsoft:latest

This should get you started. But first you'll need to populate the database:

    docker run --name foodsoft_setup --rm \
      -e SECRET_KEY_BASE -e DATABASE_URL -e REDIS_URL \
      -v `pwd`/config/app_config.yml:/usr/src/app/config/app_config.yml:ro \
      foodsoft:latest  bundle exec rake db:setup

To run the worker (recommended!), supply a different command
(see [Procfile](../Procfile) for other types):

    docker run --name foodsoft_worker \
      -e SECRET_KEY_BASE -e DATABASE_URL -e REDIS_URL \
      -v `pwd`/config/app_config.yml:/usr/src/app/config/app_config.yml:ro \
      foodsoft:latest  ./proc-start worker

To also run the cronjobs, start the previous command but substituting
`worker` with `cron`. That should give you the ingredients for a production-setup.
With the help of a front-end webserver doing ssl, of course.


### Run (docker-compose)

In practice, you'd probably want to use docker-compose. If you know Docker well enough,
you'll have no problem to set this up. For inspiration, look at the
[foodcoops.net production setup](https://github.com/foodcoops/foodcoops.net).

