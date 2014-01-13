FoodsoftVokomokum
=================

This plugin integrations 
[foodsoft](https://github.com/foodcoops/foodsoft)
with the ordering system of [Vokomokum](http://www.vokomokum.nl/), a Foodcoop
based in Amsterdam, The Netherlands. It features:
* login using an existing session cookie,
* automatic user creation on successful login, and
* uploading of ordergroup totals to the Vokomokum system (in progress).


Configuration
-------------
This plugin is configured in the foodcoop configuration in foodsoft's
"config/app\_config.yml":
```
  # Vokomokum members website url
  vokomokum_members_url: http://members.vokomokum.nl/

  # Vokomokum order website url
  vokomokum_order_url: http://order.vokomokum.nl/

  # Vokomokum login for submitting fresh amounts
  vokomokum_order_user: 123
  vokomokum_order_password: secret password
```

There are no default values, so you need to set them. This is intentional.
