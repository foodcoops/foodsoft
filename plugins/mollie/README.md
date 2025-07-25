# FoodsoftMollie


This plugin adds support for various online payment methods to Foodsoft, using [Mollie](https://www.mollie.com), a Dutch payment provider who offers this service in the European Economic Area (EEA).

> Currently, `v1.0.1` ONLY iDEAL payments are supported

## Setup

* Make sure the `Mollie` gem is uncommented in foodsoft's [Gemfile](../../Gemfile).
* Enter your Mollie account details in [config/app_config.yml](../../config/app_config.yml)`

```yaml
  # Enable the plugin option
  use_mollie: true
  # Mollie payment settings
  mollie:
    # API key for account as is provided by Mollie (check your Mollie dashboard)
    api_key: test_1234567890abcdef1234567890abcd
    # Charge transaction fee as provided by mollie api 
    # When false: fees are not added to the total amount so the coop will pay any fee related to the transaction
    charge_fees: true
    # Tax to apply on the fee (which is communicated by Mollie without tax!!)
    tax: 21
    # Only EUR supported (in the plugin at this time, Mollie does support other currencies) so this has to match the foodcoop's currency
    currency: EUR
```

When charge_fees is set `true`, the transaction fee will be added on each payment. At the moment fees are only supported with EUR.
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

## Testing

For testing it is helpful to allow Mollie to execute the callback, assuming you have an endpoint which can be reached (e.g. external address)
For this to work: add a file `callback_url.txt` in the `tmp` folder with a single line:

```txt
http://your_external_address.here
```

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! BE SURE TO USE THE MOLLIE TEST API_KEY WHEN TESTING
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

## SSL

bundle exec rails server --binding=0.0.0.0 -b 'ssl://0.0.0.0:3001?key=config/local-certs/privkey.pem&cert=config/local-certs/fullchain.pem'