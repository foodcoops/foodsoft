FoodsoftVokomokum
=================

This plugin integrations 
[foodsoft](https://github.com/foodcoops/foodsoft)
with the ordering system of [Vokomokum](http://www.vokomokum.nl/), a Foodcoop
based in Amsterdam, The Netherlands. It features:
* login using an existing session cookie,
* automatic user creation on successful login, and
* uploading of ordergroup totals to the Vokomokum system (pending).


Configuration
-------------
This plugin is configured in the foodcoop configuration in foodsoft's
"config/app\_config.yml":
```
  # Vokomokum members website url
  vokomokum_login_url: http://members.vokomokum.nl/
```
