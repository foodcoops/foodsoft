# Foodsoft Invoices Plugin

This plugin adds comprehensive invoice functionality to the [Foodsoft](https://github.com/foodcoops/foodsoft) system.

## Features

The plugin will provide the following features:

- Group Order Invoices - Invoices for individual group orders
- Ordergroup Invoices - Invoices that can span multiple group orders for the same ordergroup
- PDF generation for invoices
- Email notifications for invoices
- SEPA integration for payment processing
- Administrative features for invoice management

## Installation

1. Add the plugin to your Gemfile:
   ```ruby
   gem 'foodsoft_invoices', path: 'plugins/invoices'
   ```

2. Run bundle install:
   ```
   bundle install
   ```

3. Enable the plugin in your foodsoft configuration:
   ```yml
   use_invoices: true
   ```

## Development

This plugin is currently under development. The initial version provides the basic infrastructure for the invoice functionality, with additional features to be added in subsequent releases.

## Migrations

To install the required database migrations, run the following rake task:

```
rake foodsoft_invoices_engine:install:migrations
```

Then run the migrations with:

```
rake db:migrate
```

## Configuration

The plugin provides several configuration options that can be set in your `app_config.yml`:

- `use_invoices` - Enable or disable the plugin (default: false)
- `contact.tax_number` - The tax number to be displayed on invoices
- `group_order_invoices.vat_exempt` - Set to `true` if your organization is VAT exempt (default: false)

Example configuration:

```yaml
use_invoices: true
contact:
  tax_number: "123456789"
group_order_invoices:
  vat_exempt: true
```

## Contact

Most of the code was originally written by @viehlieb. The code was ported to this plugin by Robert (rw@roko.li). It is part of the Foodsoft project. Original sources may be available in [Local-IT Gitlab](https://git.local-it.org/Foodsoft/foodsoft/src/branch/automatic_group_order_invoice).