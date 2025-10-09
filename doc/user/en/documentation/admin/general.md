---
title: Overview
description: Functional overview and application possibilities of Foodsoft
published: true
date: 2021-11-26T11:06:26.697Z
tags: 
editor: markdown
dateCreated: 2021-04-20T19:57:55.363Z
---

# Introduction
This part of the documentation describes the functions of Foodsoft that are required for setup and administration. These functions are only available to Foodsoft users with the appropriate access rights (see [User Management](/en/documentation/admin/users)).

The functions of Foodsoft are constantly being expanded, sometimes a new function may not yet be documented here. Please contribute yourself by adding a description, or at least a heading in the appropriate place.

# Functional overview - what Foodsoft can do

## Typical food coop processes and the respective support from Foodsoft

This is what a typical weekly schedule in a food coop with a weekly ordering rhythm could look like:

1.  Saturday:
FC member creates **Foodsoft orders**, open from Saturday to Wednesday, sends **a message to everyone via Foodsoft** for information.
2.  Saturday to Wednesday:
FC members place or change their **orders via Foodsoft**; to do this, they must have previously topped up their credit, and can only order until the credit is exhausted. The credit remains untouched for the time being and is only "reserved" - in Foodsoft this is displayed as "available credit".
3.  Wednesday:
The status of the orders is frozen, FC members can no longer change their orders, **lists of orders** (only contain the total number of articles for the food coop) are sent **from Foodsoft to the suppliers**.
4.  Thursday:
FC member creates **order lists in Foodsoft with the pickup days function** and prints them out, one sorted by order groups, one sorted by articles and places these order lists in the storage room.
5.  Thursday to Friday:
Suppliers deliver ordered articles to the storage room; FC member accepts orders via **Foodsoft** and notes **deviations between order and deliveries**.
6.  Friday = **Pickup day**:
Members pick up their ordered articles in the storage room, the printed order lists help them to find their articles. Paper lists are available in the storage room where members can enter the deposit for empty containers they have returned, deviations from their order and what they have received, as well as the actual weight or price for articles with varying weight. In the future, there will be a Foodsoft app instead of the paper lists, via which this information can be entered directly into Foodsoft.

In parallel, the following processes are also taking place:

1. **Members top up their Foodsoft credit** by transferring money to the Foodsoft bank account via bank transfer using a payment reference code generated in Foodsoft;
    
2. An FC member with e-banking access to the bank account regularly imports the **booking data of the bank account into Foodsoft**, e.g. once a day on weekdays in the morning, and/or when they receive notifications about new account receipts via the e-banking app. Members' transfers for credit are automatically credited to their Foodsoft credit via the payment reference codes.
3. An FC member transfers the paper lists from the storage room to Foodsoft by crediting the deposit to the members' credit, adjusting orders to the actual quantities received and crediting or debiting difference amounts for articles with variable costs to the members' credit.
4. Suppliers send invoices to the food coop with their deliveries, by post or by email; FC members transfer these **invoices to Foodsoft** and check to what extent the amounts deducted from the members' credit for the orders match those of the invoices, and release them for payment in Foodsoft (provided that point 2 has also been completed).
5. An FC member with access to the e-banking of the FC bank account **pays released invoices** by selecting invoices from the list of unpaid invoices in Foodsoft and releasing the transactions in the e-banking app.
6. An FC member **settles completed orders in Foodsoft** for which an invoice has already been entered and paid. This means that the credit previously only reserved for orders is finally deducted from the members, it appears on their **account statement in Foodsoft**.
7. An FC member deducts the **membership fees** from the members' credit monthly via **Foodsoft**.
8. Members can exchange **messages in Foodsoft**, which they receive by email, decisions can be made via **polls**, and upcoming **tasks** are advertised via Foodsoft and FC members sign up for them.

## Application variants of Foodsoft

There are many application variants of Foodsoft, depending on which of the
functions of Foodsoft are used or not used. So that the
Foodsoft can be set up and used correctly in any case,
we have tried to list typical use cases below.

|                     |   |   |   |   |
| ------------------- | - | - | - | - |
| Function / Variant | 1 | 2 | 3 | 4 |
| Ordering           | x | x | x | x |
| Credit            |   | x | x | x |
| Invoices          |   |   | x | x |
| Bank connection       |   |   |   | x |

### Variant 1: only ordering

Even if you only use Foodsoft for ordering, you should definitely also settle your orders (see [Settle order](#anchor-64)). This tells Foodsoft that the order is only historically relevant. Otherwise, it will appear on the pickup days as well as in the order management. At some point, the pages will become so long that they take forever to load.

If you do not use Foodsoft for your finances, you should

- activate *Settle members manually* under Administration->Settings->Finances. This means there are no bookings on the accounts when you settle the orders.
- If you also set *Minimum account balance* to e.g. *-1000*, then you can save yourself the trouble with the "start-up money".

### Variant 2: orders and credit, no invoices

When settling orders, the corresponding credit is deducted from the members' Foodsoft accounts. For this, it is also necessary to create an invoice. The idea is that a digital copy of the supplier's invoice is created in Foodsoft. This may sound like a little extra effort, but it allows for a better overview and division of labor in the food coop. If you still do not want to create "real" invoices, you must at least create a pseudo-invoice to be able to settle orders. These
should:

- Be assigned to the order
- Invoice amount = order amount
- Be marked as paid by entering a date in the field

### Variant 3: no bank connection

- Transfer credit from e-banking to Foodsoft manually
- Mark invoices as paid manually

### Variant 4: full use

As described under *Functional overview*.

### Optional functions

The following functions can optionally be partially deactivated,
if they are not needed, so that they do not appear at all:

* Messages
* Task and apple point system
* Polls
* WIKI
* Document management

# Menus for Administration

With administration rights, the Foodsoft menu is extended compared to the standard rights (see [User management](/en/documentation/admin/users)):

![menues-admin.gif](/uploads-de/admin_general_menues-admin.gif)


| Menu                | Submenu | [Permission(s)](/en/documentation/admin/users) |
| ------------------- | --------- | --------------- |
| Orders | [Order management](/en/documentation/admin/orders) | Orders |
| Articles | Suppliers |  |
| Articles | Warehouse |  |
| Articles | Categories |  |
| Finances | Overview | Finances |
| Finances | [Bank accounts](/en/documentation/admin/finances/bank-accounts) | Finances |
| Finances | [Manage accounts](/en/documentation/admin/finances/accounts)| Finances |
| Finances | [Settle orders](/en/documentation/admin/orders) | Finances |
| Finances | [Invoices](/en/documentation/admin/finances/) | Finances |
| Administration | [Users, order groups, work groups, message groups](/en/documentation/admin/users) | Admin |
| Administration | [Settings](/en/documentation/admin/settings) | Admin |

# Set up Foodsoft

> **Austria**: IG Foodcoops operates a server on which Foodsoft is installed, and food coops can have their own Foodsoft instance activated. So you don't have to worry about a server and the installation of Foodsoft yourself, although that is of course also possible.
{.is-success}


If you are in the process of founding a new food coop, you can first try out Foodsoft in the [demo instance](/en/documentation/admin/foodsoft-demo). If you are sure that you want to use it, the following steps are necessary or recommended:


## Necessary steps

1. Install or activate a Foodsoft instance on a web server
     - [Use an existing server](/en/documentation/admin/request-foodsoftinstance) on which Foodsoft is already installed
     - On your own web server: [Foodsoft Installation/Setup](/en/documentation/development/first-steps)
1. [General settings](/en/documentation/admin/settings)
1. [User management](/en/documentation/admin/users) Create users and order groups, set up work groups and permissions
1. [Create suppliers, articles and categories](/en/documentation/admin/suppliers)

## Optional steps

- [Create documents, information and instructions for food coop members](/en/documentation/usage/sharedocuments)
- [Connect bank account with Foodsoft](/en/documentation/admin/finances/bank-accounts)
- ...


# Use Foodsoft

- [Create users and order groups](/en/documentation/admin/users)
- [Create suppliers and articles](/en/documentation/admin/suppliers)
- [Create warehouse](/en/documentation/admin/storage)
- [Create orders](/en/documentation/admin/orders)
- [Member accounts for credit](/en/documentation/admin/finances/accounts)
- [Create invoices](/en/documentation/admin/finances/invoices)
{.links-list}

## General tips

- [Demo installations of Foodsoft](/en/documentation/admin/foodsoft-demo) Here you can test Foodsoft and try something out without breaking anything in your own Foodsoft
{.links-list}
- [Term definitions](/en/documentation/admin/terms-definitions) Some terms in Foodsoft have special or multiple meanings
- [Gross, net and value added tax](/en/documentation/admin/finances/value-added-tax) How we as a food coop should deal with value added tax, and how value added tax can be taken into account in Foodsoft
- [Foodsoft lists](/en/documentation/admin/lists) General information on how to deal with list displays in Foodsoft (articles, orders, invoices, ...), which can quickly become a bit confusing