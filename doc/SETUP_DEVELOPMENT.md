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
[RVM](https://rvm.io/rvm/install),
[Ruby 2+](https://www.ruby-lang.org/en/downloads/),
[Bundler](http://bundler.io/),
[MySQL](http://mysql.com/)/[PostgreSQL](http://www.postgresql.org/)/[SQLite](http://sqlite.org/).

**Optional**:
[Redis](http://redis.io/).

### Getting started

0. Clone the repository from GitHub:

        git clone https://github.com/foodcoops/foodsoft.git

   This brings up the bleeding-edge development version, which might contain some
   unfinished parts. If you want to be safe, choose the last release:
   `git checkout $(git tag -l | grep ^v | sort -rn | head -n1)`

1. Install RVM and Ruby 2+ (if you have not done so before):

        \curl -L https://get.rvm.io | bash
        source ~/.rvm/scripts/rvm
        rvm install 2.3

    We try to keep Foodsoft compatible with Ruby 2.3 as well as any later versions,
    so if you use this and don't want to use RVM, that might actually work.

2. Install system dependencies.

   For Debian/Ubuntu, that's
   [libv8-dev](https://packages.debian.org/stable/libv8-dev)
   [libmysqlclient-dev](https://packages.debian.org/stable/libmysqlclient-dev)
   [libxml2-dev](https://packages.debian.org/stable/libxml2-dev)
   [libxslt1-dev](https://packages.debian.org/stable/libxslt1-dev)
   [libffi-dev](https://packages.debian.org/stable/libffi-dev)
   [libreadline-dev](https://packages.debian.org/stable/libreadline-dev)
   [libmagic-dev](https://packages.debian.org/stable/libmagic-dev)
   [libqtwebkit-dev](https://packages.debian.org/stable/libqtwebkit-dev):

        # Debian/Ubuntu
        sudo apt-get install libv8-dev libmysqlclient-dev libxml2-dev libxslt1-dev libffi-dev libreadline-dev libmagic-dev libqtwebkit-dev

   For CentOS/Redhat you need
   [v8](https://apps.fedoraproject.org/packages/v8)
   [community-mysql-devel](https://apps.fedoraproject.org/packages/community-mysql-devel)
   [libxml2-devel](https://apps.fedoraproject.org/packages/libxml2-devel)
   [libxslt-devel](https://apps.fedoraproject.org/packages/libxslt-devel)
   [libffi-devel](https://apps.fedoraproject.org/packages/libffi-devel)
   [readline-devel](https://apps.fedoraproject.org/packages/readline-devel)
   [file-devel](https://apps.fedoraproject.org/packages/file-devel)
   [qtwebkit-devel](https://apps.fedoraproject.org/packages/qtwebkit-devel):

        # CentOS/Redhat
        sudo yum install v8 community-mysql-devel libxml2-devel libxslt-devel libffi-devel readline-devel file-devel qtwebkit-devel

3. Install Ruby dependencies:

        bundle install

4. Setup your development environment:

        rake foodsoft:setup_development

   This will interactively prompt with several questions relating to your
   required environment.

   **Important**: After selecting your database type, `rake` will create the file `config/database.yml`,
   which then then be edited with working `username` and `password` credentials for the database. These fields
   must be added for *development* AND (temporary) *test* databases. Then continue with confirmation in rake dialogue.

5. Start rails by running:

        bundle exec rails s

6. Open your favorite browser and open the web application at:

        http://localhost:3000/

   You might want to watch a
   [kitten video](https://www.youtube.com/watch?v=9Iq5yCoHp4o)
   while it's loading.

7. Login using the default credentials: `admin/secret`

8. Change the admin password, just in case.

9. Have phun!


### Manual configuration

The rake task `foodsoft:setup_development` helps you to setup foodsoft.
If you want to have more control, you can do these steps manually as
explained here.


1. **Configure database**

   Create the database configuration from the default:

        cp config/database.yml.SQLite_SAMPLE config/database.yml

   If you are fine with using a file-based sqlite database you are all set.
   The sqlite files (`development/test/production`) will reside in the `db`
   directory. Otherwise you would want to copy one of the other
   `database.yml.*_SAMPLE` files and edit `database.yml` to suit your needs.


2. **Configure development environment**

   Again, you need to create your own copy of the default configuration:

        cp config/environments/development.rb.SAMPLE config/environments/development.rb

   Edit development.rb to specify your settings (at least the ActionMailer SMTP
   settings). If you just leave the file as is, emails will not work but
   everything else should be okay.


3. **Foodsoft settings**

   You need to create your own copy of the foodsoft configuration settings:

        cp config/app_config.yml.SAMPLE config/app_config.yml

   Edit `app_config.yml` to suit your needs or just keep the defaults for now.


4. **Create database (schema) and load defaults**

        rake db:setup

   With this, you also get a ready to go user with username 'admin' and
   password 'secret'.


5. (optional) Get **background jobs** done

   Time intensive tasks may block the web request. To run these in a separate
   task, you can install Redis and enable Resque:

   * Comment `Resque.inline = true` in `config/environments/development.rb`
   * Install [Redis](http://redis.io/) (Ubuntu package `redis-server`)
   * Run the worker: `rake resque:work QUEUE=foodsoft_notifier`

   To have look on the current queue, failed jobs etc start the resque server with
   `resque-web`.


6. (optional) **View mails in browser** instead in your logs

   We use mailcatcher in development mode to view all delivered mails in a
   browser interface.  Just install mailcatcher with gem install mailcatcher
   and start the service with

        mailcatcher

   From now on you have a smtp server listening on 1025. To see the emails go to

        http://localhost:1080


## Docker

To avoid having to go through setting up all dependencies, you can also run Foodsoft
within a docker image. While the default [`Dockerfile`](../Dockerfile) is setup for production,
[`Dockerfile-dev`](../Dockerfile-dev) is meant for development. Even better, you can
use docker-compose (using [`docker-compose-dev.yml`](../docker-compose-dev.yml)) to
setup the whole stack at once.

