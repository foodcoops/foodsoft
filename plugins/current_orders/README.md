FoodsoftCurrentOrders
=====================

Foodsoft is currently designed to work with one order at a time. In practice,
however there can be multiple orders open at the same time, with one pickup
day. The proper solution to this is to introduce the notion of order cycles,
with each order belonging to a cycle. Until that time, we have this plugin,
with screens for working on all orders that are closed-but-not-finished.

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
