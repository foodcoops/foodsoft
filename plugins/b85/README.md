# FoodsoftB85

This plugin adds support for the B85 order method (Biofakt B85 Mailbox Order Format) to Foodsoft.

## Features

- Adds the 'ftp_b85' remote order method to suppliers
- Provides the OrderB85 class for generating B85 format data
- Handles FTP upload of orders in B85 format
- Extends the Supplier model with validations for B85 suppliers
- Extends the Order model with validations for B85 orders

## Usage

Enable the plugin in your `config/app_config.yml`:

```yaml
use_b85: true
```

Then, you can select "FTP (BNN/B85)" as the remote order method for suppliers.

## About B85 Format

The B85 format is used by German organic wholesalers for remote ordering via FTP.
See https://n-bnn.de/leistungen-services/markt-und-produktdaten/schnittstelle for more information.
