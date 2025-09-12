---
title: Cellar & Inventory
description: 
published: true
date: 2021-10-03T10:03:32.358Z
tags: 
editor: markdown
dateCreated: 2021-03-25T00:55:54.248Z
---

# Cellar
Foodsoft offers the possibility of managing a cellar, that is to say a shared storage space in which the cells can come to supply without needing to reorder the suppliers, and which is regularly replenished when necessary. This device can allow
- new members, or cells that have difficulty assessing their needs, to stock up quickly without having to wait for a new order
- store larger quantities in good conditions that are not necessarily within the reach of all (flour silos, wine cellar, large cans, etc.),
- to increase the quantities ordered and thus to reduce prices.

## Orders
In Foodsoft, the wine cellar is seen as a kind of special supplier. So that cells can take products, so first of all *Define a command from the cellar*, using the button on the *Cellar Management* page accessible from the *Articles* tab of the main menu.

The creation of the command then happens exactly as for the orders to the suppliers (see [management](/en/Documentation/Administration/Products)). The command then appears like the others in the list of open orders.
The only difference is that there is no concept of tolerance.

## procurement
To supply the storeroom, start by ordering the missing products from a supplier of the boufcoop. This can be done for example by creating a special cell "Cellier", during a normal order of the boufcoop, or manually without going through foodsoft. Once the products have been delivered, select the supplier from the *Restore Cellar* drop-down list on the *Cellar Management* page accessible under the *Items* tab of the main menu. For each item, click on the blue button *Supply* to the right of its name, and between the quantity delivered. If an item does not appear in the list, it is not yet part of the cellar: then select its name in the drop-down list *Add an article to the cellar*, then proceed as before. Then check the quantities listed in the following table, and finally validate the supply by clicking on the blue button at the bottom of the page. Quantities in stock will be immediately updated.

If the order for the stocked items has been manually placed outside foodsoft, you can also add the corresponding invoice (see [finance](/en/Documentation/General/Finance)).

## Inventory
From time to time it may be necessary to inventory the actual contents of the cellar, and update the quantities recorded in Foodsoft to correspond to reality. For this, click on *Inventory cellar* from the page *Cellar management* accessible under the *Products* tab of the main menu. Then, for each product, enter the difference between the number of inventoried units and the number of registered units. For example, if Foodsoft believes that there is 10kg of flour while only 8.5kg remains, and the unit of flour is 500g, enter "-3".