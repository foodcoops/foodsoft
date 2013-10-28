FoodSoft
=========
[![Build Status](https://travis-ci.org/foodcoops/foodsoft.png)](https://travis-ci.org/foodcoops/foodsoft)
[![Code Climate](https://codeclimate.com/github/foodcoops/foodsoft.png)](https://codeclimate.com/github/foodcoops/foodsoft)
[![Dependency Status](https://gemnasium.com/foodcoops/foodsoft.png)](https://gemnasium.com/foodcoops/foodsoft)
[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/foodcoops/foodsoft/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

Web-based software to manage a non-profit food coop (product catalog, ordering, accounting, job scheduling).

More information about using this software and contributing can be found on the [wiki](https://github.com/foodcoops/foodsoft/wiki).

System requirements
-------------------

* [RVM](https://rvm.io/rvm/install)
* [Ruby 1.9.3](https://www.ruby-lang.org/en/downloads/)
* [Bundler](http://bundler.io/)

Getting started
---------------

1. Install RVM (if you have not done so before):

       \curl -L https://get.rvm.io | bash

2. Clone the repository from GitHub:

       git clone https://github.com/foodcoops/foodsoft.git

3. Install Ruby dependencies:

       bundle install

4. Setup your development environment:

       rake foodsoft:setup_development

   This will interactively prompt with several questions relating to your
   required environment.

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

Developing
----------

Have a look at [DEVELOPMENT.md](https://github.com/foodcoops/foodsoft/blob/master/doc/DEVELOPMENT.md) (outdated) and the (more recent) [Developing Guidelines](https://github.com/foodcoops/foodsoft/wiki/Developing-Guidelines) page on the wiki.

Deploying
---------

As you might have noticed, documentation is scarce and insufficient. If you
intend to deploy foodsoft in production, we would love to guide you through
the process. We can be contacted through the
[developers@foodcoop.nl](mailto:developers@foodcoop.nl) or
[foodsoft@foodcoops.net](mailto:foodsoft@foodcoops.net).

License
-------

FoodSoft - a webbased foodcoop management software
Copyright (C) 2011 Benni and Lasse

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

(See file LICENSE for the full text of the GPL)
