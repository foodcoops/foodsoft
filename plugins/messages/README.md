FoodsoftMessages
================

This plugin adds messages to foodsoft. A new 'Messages' menu entry is added below the 'Foodcoops' menu in the navigation bar.

This plugin is enabled by default in foodsoft, so you don't need to do anything
to install it. If you still want to, for example when it has been disabled,
add the following to foodsoft's Gemfile:

```Gemfile
gem 'foodsoft_messages', path: 'lib/foodsoft_messages'
```

This plugin introduces the foodcoop config option `use_messages`, which can be
set to `false` to disable messages. May be useful in multicoop deployments.

To allow members to respond to messages via email, you need the set the config
option `reply_email_domain` and handle incoming mails via one of the following
rake tasks. `foodsoft:reply_email_smtp_server` starts an SMTP server on the
port given via the environment variable `PORT` and listens until a shutdown
signal is received. If there is already a SMTP server for handling incoming
mails you can also feed every mail via a call to `foodsoft:parse_reply_email`
into foodsoft. It expects the address given in the `MAIL FROM` command via
SMTP in the environment variable `RECIPIENT` and the mail body as `STDIN`.

This plugin is part of the foodsoft package and uses the AGPL-3 license (see
foodsoft's LICENSE for the full license text).
