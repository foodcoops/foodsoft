---
title: Tutorial - How to create a new order
description: 
published: true
date: 2021-10-02T16:22:31.981Z
tags: 
editor: markdown
dateCreated: 2021-03-25T01:21:47.276Z
---

# Tutorial - How to create a new order
This tutorial will help through the process of creating an order.

## Assumtions
At this point it is assumed that `Supliers` and `Articles` already exists and are up to date! Please see the tutorials to do so.

Depending on your foodcoop updating prices and conditions are also your part of the job!

## Create order
In foodsoft it is only possible to create an order for a supplier. It is not possible to create an order based on articles which are received by different suppliers. Therefore it is quite easy to create new orders.

There are multiple posibilities:
- `Orders` - `Manage orders` - `Create new order` select supplier.
- `Articles` - `Suppliers/articles` - click on the name of the supplier - `articles` - `Create new order`

It is also possible to copy an old order: `Orders` - `Manage orders` - `Closed` - `Copy`
- Prepare new order
  - Set `Start`/`End`/`Pickup` dates
  - Set `End action`
  - (Un)select articles
- Click `Create order`

## Prepare new order
### Timing and/or dates
- `Starts at`: Has no effect, just leave it as it is.
- `Ends at`: [optional] Ending of the order and triggers the `End action`, could be empty.
- `Pickup`: [optional] This is only an information field! Because the date of pickup influences the decision or placing the order! Could be emtpy!
- `End action`: This will happen at date given by `Ends at`

The E-Mail and minimum quantity are set under `Articles` - `Suppliers/articles`.

### Available articles
Article availability changes from time to time. Unchecked `articles` will not be shown in the order.

Finally hit the `Create order`-button. The order is now be visible under `Current orders` under `Dashboard` or `Orders` - `Place order!`.