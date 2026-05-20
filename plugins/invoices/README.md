# Foodsoft Invoices Plugin

This plugin extends Foodsoft with a complete, production‑ready invoicing system for order groups. It covers single invoices per order group as well as collective invoices across multiple orders, and it supports SEPA direct debit and email delivery.

## Features

- Order group invoices (single order/order group)
- Collective orders (MultiOrders) and ordergroup invoices across multiple orders of the same order group
- PDF generation, ZIP download (all invoices of an order or a MultiOrder)
- Email delivery
- SEPA export (single and collective direct debit), including SEPA sequence types
- Automatic invoice delivery after order closing (optional)
- Administrative functions: mark as paid/SEPA downloaded, set SEPA sequence type

## Installation

1. Add the plugin to your Gemfile:
   ```ruby
   gem 'foodsoft_invoices', path: 'plugins/invoices'
   ```
2. Install dependencies:
   ```
   bundle install
   ```
3. Install and run migrations:
   ```
   rake foodsoft_invoices_engine:install:migrations
   rake db:migrate
   ```

Note: The required assets (foodsoft_invoices.js/.css) are registered via the Foodsoft AssetRegistry and precompiled. No further steps are required.

## Activation

Enable the plugin and provide a tax number (required for PDF generation) in `app_config.yml`:

```yaml
use_invoices: true
contact:
  tax_number: "DE123456789"
```

## Configuration

The plugin settings are available under Admin → Settings → Payment. The following options are available (keys in parentheses):

- Ignore minimum balance (group_order_invoices.ignore_minimum_balance)
- Automatically send invoices by email after balancing (group_order_invoices.use_automatic_invoices)
- Show deposits separately (group_order_invoices.separate_deposits)
- VAT exempt (group_order_invoices.vat_exempt)
- Payment method (group_order_invoices.payment_method)
- For SEPA export: IBAN, BIC, Creditor Identifier (group_order_invoices.iban/bic/creditor_identifier)

SEPA account holder per order group: In Admin → Order groups you can store a SEPA account holder with IBAN, BIC, mandate ID and signature date for each group. These data are used for single/collective direct debits.

Example configuration in `app_config.yml` (optional – settings can also be managed via the Admin UI):

```yaml
use_invoices: true
contact:
  tax_number: "DE123456789"
group_order_invoices:
  use_automatic_invoices: true
  vat_exempt: false
  separate_deposits: false
  # For SEPA export of the foodcoop (optional, if direct debit is used)
  iban: "DE12 3456 7890 1234 5678 90"
  bic: "GENODEF1XYZ"
  creditor_identifier: "DE98ZZZ09999999999"
```

## Usage

- Single order (order group invoices): In Finance → Balancing, expand the order. There you can
  - generate invoices for all order groups, view/download PDFs and download all as a ZIP,
  - send invoices via email,
  - set SEPA sequence types and mark them as "paid"/"SEPA downloaded".
- SEPA export: Using the links "Direct debit"/"Collective direct debit" you can generate XML files for all or selected order groups.
- Collective order (MultiOrder): Merge orders on the balancing list. For the resulting MultiOrder you can create ordergroup invoices, send them in bulk and download them as a ZIP. SEPA functions and status toggles are also available here.

## Technical notes

- Invoice number format: YYYYMMDD + four‑digit sequential number (unique per day)
- Automation: When the option is enabled, invoices are created and sent after an order is closed (event: `foodsoft.order.closed`).
- Dependencies: deface, sepa_king
- Assets: `foodsoft_invoices.js` and `foodsoft_invoices.css` are automatically registered/precompiled.

## Tests

Run the plugin tests:

```
bundle exec rspec plugins/invoices/spec
```

## Acknowledgements

Many thanks to @viehlieb for most of the original code. Port to this plugin: Robert (rw@roko.li). The plugin is part of the Foodsoft project. Origins may exist in the [Local‑IT Gitlab](https://git.local-it.org/Foodsoft/foodsoft/src/branch/automatic_group_order_invoice).