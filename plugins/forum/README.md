FoodsoftForum
=================

This plugin adds a forum to foodsoft. A new 'Forum' menu entry is added below the 'Foodcoops' menu in the navigation bar.

This plugin is enabled by default in foodsoft, so you don't need to do anything
to install it. If you still want to, for example when it has been disabled,
add the following to foodsoft's Gemfile:

```Gemfile
gem 'foodsoft_forum', path: 'lib/foodsoft_forum'
```

This plugin introduces the foodcoop config option `use_forum`, which can be
set to `false` to disable the forum. May be useful in multicoop deployments.

This plugin is part of the foodsoft package and uses the GPL-3 license (see
foodsoft's LICENSE for the full license text).
