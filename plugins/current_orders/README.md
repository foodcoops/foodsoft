FoodsoftCurrentOrders
=====================

Foodsoft is currently designed to work with one order at a time. In practice,
however there can be multiple orders open at the same time, with one pickup
day. The proper solution to this is to introduce the notion of order cycles,
with each order belonging to a cycle. Until that time, we have this plugin,
with screens for working on all orders that are closed-but-not-finished.

Important: be sure to settle orders from the previous order cycle, before
you close any. If you don't, articles from previous and current dates start
to mix up (if you do, settle the old ones asap).

* `current_orders/orders/receive` for a list of orders that can be received.
* `current_orders/orders.pdf?document=(groups|articles)` for PDFs for all
  orders that are closed but not settled.
* `current_orders/articles` to edit an order article's ordergroups in all
  orders that are closed but not settled.
* `current_orders/ordergroups` to edit an ordergroup's order articles in all
  orders that are closed but not settled.
* `current_orders/group_orders` for all articles in the user's group orders
  from orders that are not settled. Can be used as a "shopping-cart overview"
  or "checkout" page.

New menu items will be added in the "Orders" menu. Please note that members
with _Orders_ permission will now be able to edit the amounts members received
in some of these screens, something that was previously restricted to the
_Finance_ permission.

This plugin is not enabled by default. To install it, add uncomment the
corresponding line in the `Gemfile`, or add:

```Gemfile
gem 'foodsoft_current_orders', path: 'plugins/current_orders'
```

This plugin introduces the foodcoop config option `use_current_orders`, which
needs to be set to `true` to enable the plugin. This can be done in the
configuration screen or `config/app_config.yml`.

This plugin is part of the foodsoft package and uses the AGPL-3 license (see
foodsoft's LICENSE for the full license text).
