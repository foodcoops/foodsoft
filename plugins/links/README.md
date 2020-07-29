FoodsoftLinks
=================

This plugin adds links to foodsoft. A new 'Links' menu entry is added in the
navigation bar, if there are visible links for the user.

This plugin is enabled by default in foodsoft, so you don't need to do anything
to install it. If you still want to, for example when it has been disabled,
add the following to foodsoft's Gemfile:

```Gemfile
gem 'foodsoft_links', path: 'lib/foodsoft_links'
```

It can be used to link to external services related to the foodcoop.
With the indirect mode it is possible to implement a secure login to other
services. In that case Foodsoft will send a HTTP GET request and redirect
the user to the returned Location header. This allows the generation of
a one-time login URL.
A typical use-case would be that a workgroup, which is responsible for
the email account, does not need to share the login credentials and can
use a link within the Foodsoft instead.

This plugin is part of the foodsoft package and uses the AGPL-3 license (see
foodsoft's LICENSE for the full license text).
