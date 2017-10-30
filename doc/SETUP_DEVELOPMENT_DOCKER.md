# Foodsoft on Docker

This document explains setting up Foodsoft with Docker for development.
system. Another option is to run it [within an existing system](SETUP_DEVELOPMENT.md).
If instead you just want to run Foodsoft without changing its code, please refer to
[hosting](https://foodcoops.github.io/foodsoft-hosting/) or
[deployment](https://github.com/foodcoops/foodsoft/wiki/Deployment-notes).


## Requirements

* Docker (=> 1.9.1)
* Docker Compose (=> 1.4)
* Nothing more, no Ruby, MySQL, Redis etc!

For installing instructions see https://docs.docker.com/installation/.
Docker runs on every modern Linux kernel, but also with a little help on MacOS
and Windows!

## Setup

Then setup foodsoft development (this will take some time, containers needs
to be pulled from docker registry and a lot dependencies needs to be installed)

    docker-compose -f docker-compose-dev.yml run web rake foodsoft:setup_development

Do not enable mailcatcher, because this is already included as a docker image.

To avoid having to pass the `-f` argument all the time, it is recommended to setup
an alias, e.g. by adding the following line to your ~/.bashrc

    alias docker-compose-dev='docker-compose -f docker-compose-dev.yml'

then reload it by executing `. ~/.bashrc`. Following commands assume this is setup.


## Usage

Start containers (in foreground, stop them with `Ctrl-C`)

    docker-compose-dev up

Run a rails/rake command

    docker-compose-dev run --rm web rake db:migrate

Open a rails console

    docker-compose-dev run --rm web rails c

Setup the test database

    docker-compose-dev run --rm web rake db:setup RAILS_ENV=test DATABASE_URL=mysql2://root:secret@mariadb/test

Run the tests

    docker-compose-dev run --rm web ./bin/test

Jump in a running container for debugging.

    docker exec -ti foodsoft_web_1 bash


## Notes

### Receiving mails

Go to [http://localhost:1080](http://localhost:1080)

### Gemfile updates

As the gem bundle is stored in a volume, you can run

    docker-compose-dev run web bundle install
    docker-compose-dev restart web worker

Do this each time you update your `Gemfile`.

### Database configuration

To make this easier we use the environment variable `DATABASE_URL`
(and `TEST_DATABASE_URL` when using the testing script).
