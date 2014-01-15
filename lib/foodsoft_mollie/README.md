FoodsoftMollie
==============

This project adds support for iDEAL payments using Mollie to Foodsoft.

* Make sure the gem is uncommented in foodsoft's `Gemfile`
* Enter your Mollie account details in `config/environments/production.rb` (or `development.rb`)

  ```ruby
  if defined? FoodsoftMollie
    # If you want to use online payment, enter your details here.
    config.ideal_mollie.partner_id = 1234567
    config.ideal_mollie.profile_key = '89ABCDEF'
    config.ideal_mollie.test_mode = true
  end
  ```

To initiate a payment, redirect to `new_payments_mollie_path` at `/:foodcoop/payments/mollie/new`.
The following url parameters are recognised:
* ''amount'' - default amount to charge (optional)
* ''fixed'' - when "true", the amount cannot be changed (optional)
* ''title'' - page title (optional)
* ''label'' - label for amount (optional)

