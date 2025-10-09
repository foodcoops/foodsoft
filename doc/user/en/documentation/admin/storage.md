---
title: Storage & Inventory
description: Managing the food coop storage and product inventory
published: true
date: 2021-10-03T10:03:32.358Z
tags: 
editor: markdown
dateCreated: 2021-03-25T00:55:54.248Z
---

# Storage
Foodsoft offers the possibility of managing a storage, that is to say a shared storage space in which the members can come to supply without needing to reorder from suppliers, and which is regularly replenished when necessary. This feature can allow:
- new members, or groups that have difficulty assessing their needs, to stock up quickly without having to wait for a new order
- store larger quantities in good conditions that are not necessarily within the reach of all (flour silos, wine cellar, large containers, etc.),
- to increase the quantities ordered and thus to reduce prices.

## Orders
In Foodsoft, the storage is seen as a kind of special supplier. So that groups can take products, first of all *Define an order from the storage*, using the button on the *Storage Management* page accessible from the *Articles* tab of the main menu.

The creation of the order then happens exactly as for the orders to the suppliers (see [management](/en/documentation/admin/suppliers)). The order then appears like the others in the list of open orders.
The only difference is that there is no concept of tolerance.

## Procurement
To supply the storage, start by ordering the missing products from a supplier of the food coop. This can be done for example by creating a special group "Storage", during a normal order of the food coop, or manually without going through Foodsoft. Once the products have been delivered, select the supplier from the *Restock Storage* drop-down list on the *Storage Management* page accessible under the *Articles* tab of the main menu. For each item, click on the blue button *Supply* to the right of its name, and enter the quantity delivered. If an item does not appear in the list, it is not yet part of the storage: then select its name in the drop-down list *Add an article to the storage*, then proceed as before. Then check the quantities listed in the following table, and finally validate the supply by clicking on the blue button at the bottom of the page. Quantities in stock will be immediately updated.

If the order for the stocked items has been manually placed outside Foodsoft, you can also add the corresponding invoice (see [finance](/en/documentation/admin/finances)).

## Inventory
From time to time it may be necessary to inventory the actual contents of the storage, and update the quantities recorded in Foodsoft to correspond to reality. For this, click on *Inventory storage* from the page *Storage management* accessible under the *Articles* tab of the main menu. Then, for each product, enter the difference between the number of inventoried units and the number of registered units. For example, if Foodsoft believes that there is 10kg of flour while only 8.5kg remains, and the unit of flour is 500g, enter "-3".