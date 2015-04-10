FoodsoftCurrentOrders
=====================

Quick support for working with all current orders, to bridge the time until we
have full support for order cycles in foodsoft.

* `current_orders/ordergroups` to edit an ordergroup's order articles for all
  orders that are closed but not settled.
* `current_orders/articles` to edit an order article's ordergroups for all
  orders that are closed but not settled.
* `current_orders/orders.pdf?document=(groups|articles)` for PDFs for all
  orders that are closed but not settled.
* `current_orders/orders/receive` for a list of orders that can be received.
* `current_orders/group_orders` for all articles in the user's group orders
  from orders that are not settled. Can be used as a "shopping-cart overview"
  page.
