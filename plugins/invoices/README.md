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

## Configuration

The plugin provides several configuration options that can be set in your foodsoft configuration:

- `use_invoices` - Enable or disable the plugin (default: false)

Additional configuration options will be added as the plugin is developed.

## Development

This plugin is currently under development. The initial version provides the basic infrastructure for the invoice functionality, with additional features to be added in subsequent releases.

## Maintainers

This plugin is maintained by the Foodsoft core team.