FoodsoftMessages
================

This plugin adds messages to foodsoft. A new 'Messages' menu entry is added below the 'Foodcoops' menu in the navigation bar.

This plugin is enabled by default in foodsoft, so you don't need to do anything
to install it. If you still want to, for example when it has been disabled,
add the following to foodsoft's Gemfile:

```Gemfile
gem 'foodsoft_messages', path: 'lib/foodsoft_messages'
```

This plugin introduces the foodcoop config option `use_messages`, which can be
set to `false` to disable messages. May be useful in multicoop deployments.

This plugin is part of the foodsoft package and uses the GPL-3 license (see
foodsoft's LICENSE for the full license text).
