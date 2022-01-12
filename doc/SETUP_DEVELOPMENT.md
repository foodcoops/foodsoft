# Getting Foodsoft running for development

Gratulations, if you read this file locally, you have successfully cloned the
foodsoft project from the git repository. Now you are only a few steps away
from trying it out and then jumping into development.

This document describes how to setup Foodsoft for development within your local
system. Another option is to use [docker for development](SETUP_DEVELOPMENT_DOCKER.md).
If instead you just want to run Foodsoft without changing its code, please refer to
[hosting](https://foodcoops.github.io/foodsoft-hosting/) or
[deployment](https://github.com/foodcoops/foodsoft/wiki/Deployment-notes).

**System requirements**:
[rbenv](https://github.com/rbenv/rbenv),
[Ruby 2.6+](https://www.ruby-lang.org/en/downloads/),
[Bundler](http://bundler.io/),
[MySQL](http://mysql.com/) / [SQLite](http://sqlite.org/), 
[Redis](http://redis.io/) (optional).

### Getting started

1. Clone the repository from GitHub:

        git clone https://github.com/foodcoops/foodsoft.git

    This brings up the bleeding-edge development version, which might contain some unfinished parts.
    If you want to be safe, choose the last release:

        git checkout $(git tag -l | grep ^v | sort -rn | head -n1)

    *Note:* When developing on Windows you might run into issues with shell scripts because of Git auto-crlf.
    Have a look how to avoid that in the [Docker Development Setup](./SETUP_DEVELOPMENT_DOCKER.md#prerequisites-windows-only)
    instructions.

1. Install and setup rbenv and Bundler. For Debian/Ubuntu:

        sudo apt install rbenv
     
    For other distributions have a look at the rbenv [documentation](https://github.com/rbenv/rbenv).

    Add the following line to your `.bashrc`:

        eval "$(rbenv init -)"

    Install [ruby-build](https://github.com/rbenv/ruby-build):

        mkdir -p "$(rbenv root)"/plugins
        git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

    Change to the Foodsoft directory and install the [recommended](https://github.com/foodcoops/foodsoft/blob/master/.ruby-version)
    Ruby version:

         rbenv install "$(cat .ruby-version)"

    Now you can install [Bundler](https://bundler.io/):

         rbenv exec gem install bundler

1. Install system dependencies.

   For Debian/Ubuntu, that's:

        sudo apt install libv8-dev default-libmysqlclient-dev libxml2-dev libxslt1-dev libffi-dev libreadline-dev libmagic-dev

   For CentOS/Redhat you need:

        sudo yum install v8 community-mysql-devel libxml2-devel libxslt-devel libffi-devel readline-devel file-devel

1. Install Ruby dependencies:

        rbenv exec bundle install

1. Setup your development environment:

        rbenv exec rails foodsoft:setup_development

   This will interactively prompt with several questions relating to your
   required environment.

   **Important**: After selecting your database type, `rails` will create the file `config/database.yml`,
   which then then be edited with working `username` and `password` credentials for the database. These fields
   must be added for *development* AND (temporary) *test* databases. Then continue with confirmation in rails dialogue.

1. Start rails by running:

        rbenv exec rails s

1. Open your favorite browser and open the web browser at:

        http://localhost:3000/

   You might want to watch a [kitten video](https://www.youtube.com/watch?v=9Iq5yCoHp4o) while it's loading.

1. Login using the default credentials: `admin/secret`

1. Change the admin password, just in case.

1. Have phun!

For running integration tests, you also need the Chromium/Chrome web browser.
On Debian that would be `apt-get install chromium`, on Ubuntu
`sudo apt-get install chromium-browser`.

### Manual configuration

The rails task `foodsoft:setup_development` helps you to setup foodsoft.
If you want to have more control, you can do these steps manually as explained here.

1. **Configure database**

    Create the database configuration from the default:

        cp config/database.yml.SQLite_SAMPLE config/database.yml

    If you are fine with using a file-based sqlite database you are all set.
    The sqlite files (`development/test/production`) will reside in the `db` directory. Otherwise you would want to copy one
    of the other `database.yml.*_SAMPLE` files and edit `database.yml` to suit your needs.

1. **Configure development environment**

    Again, you need to create your own copy of the default configuration:

        cp config/environments/development.rb.SAMPLE config/environments/development.rb

    Edit development.rb to specify your settings (at least the ActionMailer SMTP settings). If you just leave the file as is,
    emails will not work but everything else should be okay.

1. **Foodsoft settings**

   You need to create your own copy of the foodsoft configuration settings:

        cp config/app_config.yml.SAMPLE config/app_config.yml

   Edit `app_config.yml` to suit your needs or just keep the defaults for now.

1. **Create database (schema) and load defaults**

        rbenv exec rails db:setup

   With this, you also get a ready to go user with username 'admin' and password 'secret'.

1. (optional) Get **background jobs** done

   Time intensive tasks may block the web request. To run these in a separate task, you can install Redis and enable Resque:

   * Comment `Resque.inline = true` in `config/environments/development.rb`
   * Install [Redis](http://redis.io/) (Debian/Ubuntu package `redis-server`)
   * Run the worker:

       ```
       rbenv exec rails resque:work QUEUE=*
       ```

   To have look on the current queue, failed jobs etc start the resque server with
   `resque-web`.

1. (optional) **View mails in browser** instead in your logs

   We use mailcatcher in development mode to view all delivered mails in a
   browser interface.  Just install mailcatcher with `rbenv exec gem install mailcatcher`
   and start the service with:

        mailcatcher

   From now on you have a smtp server listening on 1025. To see the emails go to:

        http://localhost:1080


## Docker

To avoid having to go through setting up all dependencies, you can also run Foodsoft
within a docker image. While the default [`Dockerfile`](../Dockerfile) is setup for production,
[`Dockerfile-dev`](../Dockerfile-dev) is meant for development. Even better, you can
use docker-compose (using [`docker-compose-dev.yml`](../docker-compose-dev.yml)) to
setup the whole stack at once.

See [Setup Development Docker](./SETUP_DEVELOPMENT_DOCKER.md) for a detailed description.