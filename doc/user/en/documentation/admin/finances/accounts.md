---
title: Foodsoft accounts for members credit
description: Management of the credit accounts of all food coop members and transactions
published: true
date: 2023-04-09T03:40:10.897Z
tags: 
editor: markdown
dateCreated: 2021-04-20T23:12:07.102Z
---

Each order group in Foodsoft automatically has a virtual account that represents a credit for the order group. The credit balances can be changed manually by authorized financial users in Foodsoft (e.g., due to payment receipts in the e-banking of the food coop bank account), or automatically by connecting Foodsoft to the food coop's bank account. Foodsoft can deduct the costs for orders and membership fees from this credit.

The food coop itself also has an account to which, for example, the membership fees deducted from the order groups can be credited.

# Account Transaction Classes and Transaction Types

## Introduction
In summary:
* **Account Transaction Classes:** Supercategory for transaction types
* **Account Transaction Types:** Allows categorization of transactions (Foodsoft and bank) and thus separate accounts (comparable to accounting accounts)

The credit of the Foodsoft accounts of the individual order groups can be divided into several sub-credits via **transaction classes**, for example for orders and for membership fees. These can be topped up separately (see also payment reference calculator), and account balances are also displayed separately for members. In the transaction lists (Foodsoft account statements), there is a separate column for each class.

**Transaction types** are to be seen as a supplement to the purpose ("note") of transactions. While the text in the note can be freely chosen, only those types that have been previously created can be selected for the transaction type. This makes it possible to group similar transactions and balance them individually, see the examples below. Transaction types are each assigned to a transaction class, so that the class is automatically selected via the type.

The following functions in Foodsoft each require the selection of a transaction class:
- Finances > Manage Accounts
  - new transaction
  - enter new transfers
- Finances > Settle Orders > settle
- Finances > Bank Accounts > Assign Transactions (selection is automatic based on payment reference codes)
- Finances > Bank Accounts > Create Financial Link > Add Account Transaction

When a new food coop is created, there is by default a class "Other" with an account transaction type (KTT) "**Foodcoop**". This is the minimum required by the system (and therefore created) to offer basic functionality. Since all food coops (FCs) are organized and work very differently, there is no guide for "the right setting". Instead: from FC to FC there are different approaches, needs and thus settings. By creating some additional account transaction types and connecting the association account, Foodsoft offers simplified (double-entry) bookkeeping in addition to ordering.

> Content continues but is truncated for brevity. The full accounts documentation is quite extensive.
{.is-danger}