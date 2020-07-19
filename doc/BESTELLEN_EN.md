
# Order
Ordering is the main part of this software and a little bit complicated.
Here I start the attempt to convert the program logic into text and
references to the corresponding controllers or models.
The relevant controller is 'OrdersController'.

## order "put into network
By this we mean the selection of articles from a specific supplier for a temporary
Order on the Internet. The relevant methods are 'OrdersController#newOrder' and the following.
Each order is represented by the class Order.

The associated articles are linked to the articles by the class 'OrderArticle'.
The attributes 'Quantity', 'Tolerance' and 'Quantity_to_order' are also stored.
These quantities represent the total order, i.e. all order groups.

## An order group orders...
The method `OrdersController#order` sends us the order page. With this
surface, the order groups can select the previously selected articles and
order. By means of the buttons live, i.e. client-side, the
prices are determined and the total price is calculated. If the total price is greater than
the current group account balance, the price column is highlighted in red and the
Order cannot be saved.

## (group) order is saved

The group order is defined by the table 'group_orers' (`GroupOrder`)
or the order and order group is linked there.

The ordered articles of the order group are represented by the table 'group_order_articles'.
('GroupOrderArticle') is registered. There the models GroupOrder
and OrderArticle are connected with each other.

For each order, the sum of the quantity, tolerance in 'GroupOrderArticle' is also displayed.
filed. However, every change to these quantities must be logged.
This is important, because later the allocation of units per ordered article
in chronological order. (see below)
This then happens in the table 'group_order_article_quantities'.
('GroupOrderArticleQuantity').

## Change of an order

The change of a group order is tricky, because the temporal
sequence must not be confused.
We therefore distinguish between two cases:

### Increase the amount of arikel.
Now we create a line in 'group_order_article_quantities'.
with exactly the quantities that were ordered in addition.
Quantity and Tolerance work analogously.

Example:
* Originally ordered: 2(2) at 5pm.
* Increase order to 4(2) at 18hur.  
  => new line with quantity = 2, tolerance = 0, and created_on = 18hur
* Now there are two lines that add up to 4(2).  
  (the totals in 'GroupOrderArticle' are updated)

### Reduce the quantities of the item.
Now you have to go back chronologically and to reduce the originally ordered
quantities.

Example from above:
* Decrease order to 2(1) by 7pm.  
  => Line with created_on = 18 o'clock is deleted and  
  in the line with created_on = 17uhr the value tolerance is changed to 1.

## Who gets how much?

This question is answered by the `group_order_article_quantites` table
solved.

Example.

* articel x with unit_quantity = 5.
  * 17 o'clock: group a orders 2(3), because she wants to get something from x in any case
  * 18 o'clock: group b ordered 2(0)
  * 19:00: group a decides that she needs more from x and changes to 4(1).

* now there are three lines in the table that look like this
  * (group a), 2(1), 17 o'clock (changed at 19 o'clock from 2(3) to 2(1))
  * (group b), 2(0), 18h
  * [group a], 2(0), 19:00.

* the allocation is then determined as follows:
  * line 1: group a gets 2
  * line 2: group b gets 2
  * line 3: group a gets 1, because now the container is already full.

* final result: total of 6(1)
  * group a gets 3 units.
  * group b gets 2 units.
  * one unit expires.


Translated with www.DeepL.com/Translator (free version)
