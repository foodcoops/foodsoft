FoodsoftSignup
==============

This project adds support for signup form to
[foodsoft](https://github.com/foodcoops/foodsoft).
At `/:foodcoop/login/signup` there is a new form where prospective members can
fill in their details and create an account (with an ordergroup). This allows
them to login to foodsoft, but only when their account is approved by an
administrator can they access all areas of the site. Typically, one would
restrict placing an order to approved accounts only.

Configuration
-------------
This plugin is configured in the foodcoop configuration in foodsoft's
"config/app\_config.yml":
```
  # membership fee substracted from balance when a new ordergroup is created
  membership_fee: 35

  # enable to to allow public signup
  signup: true

  # Array of which pages are accesible to ordergroups that are not approved.
  # Values are controller names (`pages`) or actions combined with controller
  # names (`pages#show`). If not set, the default is:
  # `home login sessions feedback pages#show pages#all group_orders#archive payments`
  unapproved_allow_access:
  - home
  - login
  - sessions
  - feedback
  - pages#show
  - pages#all
  - group_orders#archive
  - payments

  # Message to show when ordergroup is not yet approved. If not set, a concise
  # default message will be shown.
  #ordergroup_approval_msg:
  #  Your membership still needs to be approved. Please transfer €35 to account
  #  12345678 "FC Test" in Berlin, mentioning "membership fee" and your
  #  username. After up to three days, your account will be activated, and you
  #  will be able to order here.

  # Payment link to show when ordergroup is not yet approved. When this is set,
  # "%{link}" will be substituted with the link in the approval message.
  # When starting with http: or https:, this is considered to be a full url; else 
  # a Ruby name that will be evaluated on the controller.
  #ordergroup_approval_payment: new_payments_mollie_path
```
