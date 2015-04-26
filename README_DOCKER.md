# Foodsoft on Docker

This document explains setup and using docker the foodsoft with docker.

## Requirements

* Docker (=> 1.5)
* Docker Compose (=> 1.1)
* Nothing more, no ruby, mysql, redis etc!

For installing instructions see https://docs.docker.com/installation/.
Docker runs on every modern linux kernel, but also with a little help on MacOS
and Windows!

## Setup

Create docker volume for mysql data:

    mkdir -p ~/.docker-volumes/foodsoft/mysql

Setup foodsoft development data: (This will take some time, containers needs
to be pulled from docker registry and a lot dependencies needs to be installed.)

    docker-compose run app rake foodsoft:setup_development

TODO: Right know this is not gonna work because of the new database
configuration via ENV variable. See Notes below.

## Usage

Start containers (in foreground, stop them with `CTRL-C`)

    docker-compose up

Run a rails/rake command

    docker-compose run app rake db:migrate

Open a rails console

    docker-compose run app rails c

Run the tests

    docker-compose run app ./bin/test

Jump in a running container for debugging.

    docker exec -ti foodsoft_app_1 bash

## Notes

### Gemfile updates

This is bit tricky, as the gemfiles are stored in the container and so we have
to rebuild the container each time we change the Gemfile. To avoid installing
all the gems from scratch we can use this workaround:

```bash
docker-compose run app bundle update rails # Update Gemfile.lock file
docker ps -a # Look for the last exited container and grab the Container ID
docker commit -m "Updated rails" <Container ID> foodsoft_app
```

### Database configuration

TO make thins easier we use the ENV Variable DATABASE_URL. But to make this
work, the shouldn't be any config/database.yml file!
