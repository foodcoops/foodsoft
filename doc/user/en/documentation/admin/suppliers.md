---
title: Suppliers and Articles
description: Management of suppliers and articles in Foodsoft
published: true
date: 2023-01-27T13:08:29.461Z
tags: 
editor: markdown
dateCreated: 2021-04-20T21:50:56.992Z
---

# Suppliers and Articles

In Foodsoft, producers and suppliers are generally referred to as "supplier" or "suppliers", and products as "articles". Across suppliers, articles can be assigned categories (e.g., vegetables, juice, fruit, ...).

# Suppliers

"Suppliers" can be producers, but also e.g., traders or wholesalers.

## Create

Articles \> Suppliers/Articles \> Create new supplier

For more information see "Edit".

> Since a supplier can only be deleted with difficulty (see below), please only create suppliers when this is really needed. For experimenting, it's best to use a [Foodsoft demo version](/en/documentation/admin/foodsoft-demo).
{.is-warning}

## Edit

Articles \> Suppliers/Articles \> Click name

### Name

> Recommendation: regardless of the official designation, put the proper name first, e.g., "Adam Organic Farm" instead of "Organic Farm Adam". This makes it easier to find suppliers faster in alphabetically sorted lists later.
{.is-info}

### Address

Postal address of the supplier: street, house number, postal code, city.

### Phone, Phone 2 and Fax

Phone number(s) of the supplier and - if available - fax number

### Website

URL (link) to the supplier's homepage, starting with `http://` or `https://`. Only visible with appropriate authorization, therefore not suitable as general information for orderers.

### Category (supplier category)

- **Consumption**: Suppliers whose invoices are paid from the order credit of members, e.g., vegetable farmer, dairy, ...
- **Operating costs**: Supplier whose invoices are paid by the association or membership fees, such as storage room rent, electricity, ...
- **Other**: Purchases by the association such as cleaning supplies, storage room equipment, ...

The selection of the category only affects the accounting representation of the balance sheet (Finances \> Overview \> Create report).

### IBAN

Entering the IBAN of the producer's bank account is required when the food cooperative bank account is linked to Foodsoft, and invoices should be automatically marked as paid.

- One-time activation of the IBAN field under Administration \> Settings \> Finances \> Use IBAN
- Supplier: Entry of the IBAN without spaces required
- No IBAN validation is performed, meaning it is possible to enter an invalid IBAN. Recommendation therefore: Check IBAN e.g., via online IBAN validators

### Minimum Order Quantity

This field can be used in two ways:
- as text that is displayed when ordering
- as a number for a monetary amount that represents a minimum order value. When ordering, this value and the current order value from all order groups are then displayed. When creating the order, the option "... only if minimum order value is reached" can be selected.

> When specifying a number, a currency or currency symbol can additionally be specified after the number, e.g., "40 €".
{.is-success}

> An automatic minimum piece number is not possible, therefore convert to monetary value or agree on Euro value with supplier instead.
{.is-info}

## Delete Supplier

> The "Delete" function should be used with special caution! Better to rename suppliers instead of creating new ones and deleting old ones.
{.is-warning}

Since orders and invoices can be linked to a supplier, a supplier is not really deleted. It remains in the database and only disappears from the supplier lists, with the exception of the list under Finances \> Create invoice, where the supplier remains visible marked with a †. The supplier can no longer be edited, it is also not possible to create a new supplier with the same name or the same IBAN.

> You can rename suppliers from whom you are currently not (anymore) ordering, e.g., with "ZZ" at the beginning, so that they are at the very end of the selection lists and it is clear that they are dormant. This way they don't disturb the list so much, and still remain editable/reactivatable.
{.is-info}

# Articles

## Create Articles

Articles \> Suppliers \> Select supplier \> New article

### Basic Information

- **Name**: Product name as it should appear in orders
- **Unit**: The unit in which the product is sold (e.g., kg, piece, liter)
- **Price**: Price per unit
- **Tax**: VAT rate (if applicable)
- **Deposit**: Deposit amount for returnable containers

### Categories

Articles can be assigned to categories to organize them better in the ordering interface:
- Vegetables
- Fruits  
- Dairy
- Grains & Cereals
- Beverages
- etc.

### Availability

- **Available**: Whether the article is currently available for ordering
- **Stock quantity**: For warehouse articles, the current stock level

## Edit Articles

Articles can be edited by going to Articles \> Suppliers \> Select supplier \> Click on article name.

Changes to article prices create a new price entry, preserving the price history for past orders.

## Import Articles

For suppliers with many articles, Foodsoft supports importing article lists via CSV files or direct integration with some supplier systems.

> Detailed import instructions are available in the supplier management interface.
{.is-info}