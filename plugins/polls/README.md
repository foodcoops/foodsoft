FoodsoftPolls
=============

This plugin adds polls to foodsoft. A new 'Polls' menu entry is added below the 'Foodcoops' menu in the navigation bar.

This plugin is enabled by default in foodsoft, so you don't need to do anything
to install it. If you still want to, for example when it has been disabled,
add the following to foodsoft's Gemfile:

```Gemfile
gem 'foodsoft_polls', path: 'lib/foodsoft_polls'
```

This plugin introduces the foodcoop config option `use_polls`, which can be
set to `false` to disable polls. May be useful in multicoop deployments.

This plugin is part of the foodsoft package and uses the AGPL-3 license (see
foodsoft's LICENSE for the full license text).
