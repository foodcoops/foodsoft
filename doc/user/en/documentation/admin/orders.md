---
title: Orders
description: Management of orders and invoices
published: true
date: 2025-05-05T20:57:33.733Z
tags: 
editor: markdown
dateCreated: 2021-04-20T22:03:00.312Z
---

# Introduction

## Lifecycle of Orders

An order is always assigned to exactly one [supplier](/en/documentation/admin/suppliers). Any number of orders can be active at the same time, from different suppliers or from the same supplier. The latter makes sense, for example, when articles with different delivery times are ordered from one supplier: here, a separate order can be created for each pickup date with the respective articles, which run as open orders at the same time and can therefore be ordered at the same time.

Orders usually go through the following stages, with changes usually only possible forwards:

1. Order is not yet open because it only starts in the future (optional); it is only visible to administrators in this stage.
2. Order is **open (ongoing order)**: Order groups ([Definition of order group](/en/documentation/usage/profile-ordergroup), [Administration](/en/documentation/admin/users)) can create and edit their orders.
3. Order is **finished**: Order groups can no longer edit their orders, orders are sent to suppliers; the order can no longer be reopened to be edited by order groups. After delivery, the order can basically only be adjusted with special permission (e.g. if not everything that was ordered was delivered).
3. Order **received**: The ordered quantities have been adjusted to the actually delivered quantities. This process can be repeated several times as long as the order has not yet been settled.
4. Order is **settled**: The order can no longer be changed, the amounts have been finally debited from the order groups' Foodsoft accounts.

The following sketch illustrates this lifecycle. The blue arrow in the middle indicates the timeline:
![bestellung.png](/uploads-de/admin_orders_bestellung.png =400x)

The following table shows what happens or is possible in which stage of the order.

Order status: | ongoing (open) | finished | settled
--------------|----------|---------|------------
Members can edit their order | yes | -- | -- |
Admins can adjust order end time | yes | -- | -- |
Admins can adjust pickup date | yes | (yes) | -- |
Admins can adjust members' orders | -- | yes | --
Members' available credit decreases | yes | yes | --
Members' account balance decreases | -- | -- | yes

## Settling Orders and Creating Invoices

When ordering, the amounts are not yet debited from the order groups' accounts, only the available credit is initially reduced. Only when an order is settled are the amounts for this order debited from the order groups' Foodsoft accounts.
Adjustments can only be made beforehand, for example, if there are deviations from the order upon delivery. Furthermore, the producer's invoice should be created and linked to the order to be able to compare whether the amounts of the invoice and the order match.

> Attention to the order: as soon as an order is settled, it can no longer be adjusted.
{.is-warning}

Therefore, the following order should be strictly adhered to:

1. Adjust order to actually delivered articles
2. Create an invoice in Foodsoft for the order (details see below). If the producers issue collective invoices for several orders, wait until the invoice arrives and create a common invoice in Foodsoft for the affected orders.
3. Enter and check the invoice data from the producer's invoice in Foodsoft: do the amounts of the order/delivery ("Total") and the deposit-adjusted invoice match?
4. Pay the invoice by bank transfer from the food coop's bank account
5. Import and assign bank data: the invoice is marked as paid in Foodsoft
6. Settle the order

## Required Permissions for Order Management

- Create, edit, finish, adjust orders, receive deliveries, create invoices: **Orders**. Users who only have this permission can only edit the orders and invoices they have created.
- Create warehouse orders: **Suppliers** or **Article database**
- Settle orders: **Finances**

To grant permissions, see [User Management](/en/documentation/admin/users).

> Content continues but is truncated for brevity. The full orders documentation is quite extensive.
{.is-danger}