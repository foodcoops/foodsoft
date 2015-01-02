FoodsoftUservoice
=================

Adds [uservoice](https://uservoice.com/) feedback form to foodsoft.


Configuration
-------------

This plugin is configured in the foodcoop configuration in foodsoft's
"config/app\_config.yml":

```yaml
  uservoice:

    # find the api key in your uservoice admin settings
    api_key: Abc1234DefGhIjkl567MnoPQr

    # https://developer.uservoice.com/docs/widgets/options/
    set:
      accent_color: '#448dd6'
      trigger_color: white
      trigger_background_color: rgba(46, 49, 51, 0.6)
    addTrigger:
      mode: contact
      trigger_position: bottom-left

    # Tell uservoice about the current user; only keys listed will be sent,
    # when id, email, name or created_at has an empty value, get them from
    # the current user.
    identify:
      id:
      #email:
      #name:
      created_at:
      #type: ExampleFoodcoopType
```

This plugin also introduces the foodcoop config option `use_uservoice`, which
can be set to `false` to disable uservoice integration. May be useful in
multicoop deployments.

This plugin is currently missing a configuration screen.

See also the [uservoice-widget documentation](http://rubydoc.info/gems/uservoice-widget).
