# Foodsoft on Docker

This document explains setting up and using Foodsoft with Docker.

## Requirements

* Docker (=> 1.9.1)
* Docker Compose (=> 1.4)
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

## Usage

Start containers (in foreground, stop them with `CTRL-C`)

    docker-compose up

Run a rails/rake command

    docker-compose run app rake db:migrate

Open a rails console

    docker-compose run app rails c

Setup the test database

    docker-compose run app rake db:setup RAILS_ENV=test DATABASE_URL=mysql2://root:secret@mysql/test

Run the tests

    docker-compose run app ./bin/test

Jump in a running container for debugging.

    docker exec -ti foodsoft_app_1 bash

Receiving mails

Go to http://localhost:1080.

## Notes

### Gemfile updates

As we use a special container (`bundle`, see `docker-compose.yml`) you only
have to run the bundle command as normally: `docker-compose run app bundle`

### Database configuration

To make this easier we use the environment variable `DATABASE_URL`
(and `TEST_DATABASE_URL` when using the testing script).
