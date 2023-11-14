FoodsoftMollie
==============

This project adds support for various online payment methods using Mollie to Foodsoft.

* Make sure the gem is uncommented in foodsoft's `Gemfile`
* Enter your Mollie account details in `config/app_config.yml`

```yaml
  use_mollie: true
  # Mollie payment settings
  mollie:
    # API key for account: 1234567, website profile: FooInc
    api_key: test_1234567890abcdef1234567890abcd
    # Transaction fee as provided by mollie api (only EUR supported)
    charge_fees: true
    currency: EUR # should match the foodcoop's currency
```

When charge_fees is set true, the transaction fee will be added on each payment. At the moment fees are only supported with EUR.
It is disabled by default, meaning that the foodcoop will pay any transaction costs (out of the margin).

To initiate a payment, redirect to `new_payments_mollie_path` at `/:foodcoop/payments/mollie/new`.
The following url parameters are recognised:
* ''amount'' - default amount to charge (optional)
* ''fixed'' - when "true", the amount cannot be changed (optional)
* ''title'' - page title (optional)
* ''label'' - label for amount (optional)
* ''min'' - minimum amount accepted (optional)

This plugin also introduces the foodcoop config option `use_mollie`, which can
be set to `false` to disable this plugin's functionality. May be useful in
multicoop deployments.
