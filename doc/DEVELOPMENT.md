README for DEVELopment Project Setup
====================================

Gratulations, you have successfully cloned the foodsoft project
from the git repository. Now you are only a few steps away from
trying it out and then jumping into development. (This manual presumes
you have ruby and rails setup.)

(1) Configure datebase
----------------------
Create the database configuration from the default:

    cp config/database.yml.SAMPLE config/database.yml

If you are fine with using a file-based sqlite database you are all set.
The sqlite files (development/test/production) will reside in the "db" directory.
Otherwise you would want to edit database.yml to suit your needs (MySQL whatever).
	

(2) Configure development environment
-------------------------------------
Again, you need to create your own copy of the default configuration:

	cp config/environments/development.rb.SAMPLE config/environments/development.rb

Edit development.rb to specify your settings (at least the ActionMailer SMTP settings).
If you just leave the file as is, emails will not work but everything else should be okay.


(3) Foodsoft settings
---------------------
You need to create your own copy of the foodsoft configuration settings:

	cp config/app_config.yml.SAMPLE config/app_config.yml

Edit app_config.yml to suit your needs or just keep the defaults for now.


(4) Secret Token
-------------------
The user session are stored in cookies. Do avoid misusing the cookies and its sensitive information, rails
will encrypt it with a token. So copy the config file

   cp config/initializers/secret_token.rb.SAMPLE config/initializers/secret_token.rb

and modify the token!!


(5) Required ruby and gems
-------------------
We recommend to use rvm (https://rvm.beginrescueend.com/). Install rvm and get the latest ruby (>= 1.9.3).
If installed you only need to install the gem bundler:

    gem install bundler

After that you get the other gems easily with (from project root):

    bundle install


(6) Create database (schema) and load defaults
--------------------------
	rake db:setup

With this, you also get a ready to go user with username 'admin' and password 'secret'.


(7) Try it out!
---------------	
Start the WEBrick server to try it out:

	bundle exec rails s


(8) (optional) Get background jobs done
---------------------------------------
We use for time intensive tasks a background job queue, at the moment resque with redis as key/value store.
Install redis (in ubuntu the package redis-server works out of the box) and start the resque worker with:

    rake resque:work QUEUE=foodsoft_notifier

To have look on the current queue, failed jobs etc start the resque server with

    resque-web


(9) (optional) View mails in browser instead in your logs
---------------------------------------------------------
We use mailcatcher in development mode to view all delivered mails in a browser interface.
Just install mailcatcher with gem install mailcatcher and start the service with

    mailcatcher

From now on you have a smpt server listening on 1025. To see the emails go to

    http://localhost:1080