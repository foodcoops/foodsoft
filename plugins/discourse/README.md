FoodsoftDiscourse
=================

This plugin adds the possibility to log in via Discourse or act as and SSO
provider for Discourse. A new button is added to the login screen if enabled.

This plugin is enabled by default in foodsoft, so you don't need to do anything
to install it. If you still want to, for example when it has been disabled,
add the following to foodsoft's Gemfile:

```Gemfile
gem 'foodsoft_discourse', path: 'plugins/foodsoft_discourse'
```

This plugin introduces the foodcoop config option `discourse_url`, which takes
the URL for the Discourse installation (e.g. `https://forum.example.com`) and
the config option `discourse_sso_secret`, which must be set to the same values
as configured in the `sso secret` setting of the Discourse installation. The
plugin will be disabled if not both config options are set.

If `discourse_sso` is set to `true` Foodsoft will act as an SSO provider for
Discourse. The `sso url` for Discourse is `/discourse/sso` relative to root url
of Foodsoft (e.g. `https://foodsoft.example.com/f/discourse/sso`).

## Redirect targets

The SSO handshake redirects to more than one host: Foodsoft sends the payload to
`discourse_url`, and Discourse redirects it back to the `return_sso_url` it was
given -- which for "log in via Discourse" is Foodsoft's own callback. Redirects are
only followed to hosts Foodsoft knows about, matched exactly on
`scheme://host[:port]` (subdomains are not implied):

- the root url of this Foodsoft instance,
- `discourse_url`,
- `discourse_redirect_hosts` -- for installations with several Discourse (or other
  trusted) front-ends. Either a single URL or a list:

```yaml
discourse_redirect_hosts:
  - https://forum.example.com
  - https://blog.example.net
```

A redirect to any other host is refused with a "Redirect not allowed" message rather
than leaking the SSO payload (which contains the user's email, name, username and
external id) to it.

This plugin is part of the foodsoft package and uses the AGPL-3 license (see
foodsoft's LICENSE for the full license text).
