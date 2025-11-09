Foodsoft
=========

[![Build Status](https://github.com/foodcoops/foodsoft/workflows/Ruby/badge.svg)](https://github.com/foodcoops/foodsoft/actions)
[![Coverage Status](https://coveralls.io/repos/foodcoops/foodsoft/badge.svg?branch=master)](https://coveralls.io/r/foodcoops/foodsoft?branch=master)
[![Docs Status](https://inch-ci.org/github/foodcoops/foodsoft.svg?branch=master)](http://inch-ci.org/github/foodcoops/foodsoft)
[![Code Climate](https://codeclimate.com/github/foodcoops/foodsoft.svg)](https://codeclimate.com/github/foodcoops/foodsoft)
[![Docker Status](https://img.shields.io/docker/cloud/build/foodcoops/foodsoft.svg)](https://hub.docker.com/r/foodcoops/foodsoft)
[![Documentation](https://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/foodcoops/foodsoft)

Web-based software to manage a non-profit food coop (product catalog, ordering, accounting, job scheduling).

A food cooperative is a group of people that buy food from suppliers of their own choosing. A collective do-it-yourself supermarket. Members  order their products online and collect them on a specified day. And all put in a bit of work to make that possible. Foodsoft facilitates the process.

If you're a food coop considering to use foodsoft, please have a look at the [wiki page for foodcoops](https://github.com/foodcoops/foodsoft/wiki/For-foodcoops). When you'd like to experiment with or develop foodsoft, you can read [how to set it up](https://github.com/foodcoops/foodsoft/blob/master/doc/SETUP_DEVELOPMENT.md) on your own computer.

More information about using this software and contributing can be found on the [wiki](https://github.com/foodcoops/foodsoft/wiki).

Roadmap
-------

If you'd like to see what is currently bring prioritised for development, check [our roadmap](https://github.com/orgs/foodcoops/projects/1). If you'd like to influence the roadmap, please join our [monthly community call](https://forum.foodcoops.net/t/foodsoft-monthly-community-call/573/6). As of March 2023, Foodsoft has limited development capacity but we are trying to build this up once more. For now, we try to prioritise what we work on, in order to focus our efforts. If your proposed changes are waiting for some time without review, please join the community call to discuss.

Developing
----------

> Foodsoft development needs your help! If you want to hack/triage/organise to improve the software, please consider joining our monthly community calls which are announced on [this forum thread](https://forum.foodcoops.net/t/foodsoft-monthly-community-call/573/6). In these calls, we check in with each other, discuss what to prioritise and try to make progress with development and community issues together.

Get foodsoft [running locally](doc/SETUP_DEVELOPMENT.md),
then visit our [Developing Guidelines](https://github.com/foodcoops/foodsoft/wiki/Developing-Guidelines)
page on the wiki.

Get a foodsoft dev-environment running in the browser with Gitpod

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/foodcoops/foodsoft)

Follow these [instructions](doc/SETUP_DEVELOPMENT_GITPOD.md) to complete setup from within the Gitpod workspace. 

Deploying
---------

Setup foodsoft to [run in production](doc/SETUP_PRODUCTION.md), or join an existing
[hosting platform](https://foodcoops.net/foodsoft-hosting/).

You can find a ci/cd deployment of the current master on: [master.ci.foodcops.net](https://master.ci.foodcops.net) (admin : secret)

License
-------

Foodsoft is licensed under the [AGPL](https://www.gnu.org/licenses/agpl-3.0.html)
license (version 3 or later). Practically this means that you are free to use,
adapt and redistribute the software, as long as you publish any changes you
make to the code.

For private use, there are no restrictions, but if you give others access to
Foodsoft (like running it open to the internet), you must also make your
changes available under the same license. This can be as easy as
[forking](https://github.com/foodcoops/foodsoft/fork) the project on Github and
pushing your changes. You are not required to integrate your changes back into
the main Foodsoft version (but if you're up for it that would be very welcome).

To make it a little easier, configuration files are exempt, so you can just
install and configure Foodsoft without having to publish your changes. These
files are marked as public domain in the file header.

If you have any remaining questions, please
[open an issue](https://github.com/foodcoops/foodsoft/issues/new) or open a new
topic at the [forum](https://forum.foodcoops.net).

Please see [LICENSE](LICENSE.md) for the full and authoritative text. Some
bundled third-party components have [other licenses](vendor/README.md).

Thanks to [Icons8](http://icons8.com/) for letting us use their icons.
