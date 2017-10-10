FoodsoftDocuments
=================

This plugin adds documents to foodsoft. A new 'Documents' menu entry is added below the 'Foodcoops' menu in the navigation bar.

This plugin is not enabled by default. To install it, add uncomment the
corresponding line in the `Gemfile`, or add:

```Gemfile
gem 'foodsoft_documents', path: 'lib/foodsoft_documents'
```

Then activate the plugin (explained [here](https://github.com/foodcoops/foodsoft/wiki/Plugins#installing-a-plugin)):

```
bundle install
rake railties:install:migrations
rake db:migrate
```

This plugin introduces the foodcoop config option `use_documents`, which can be
set to `true` to enable documents. May be useful in multicoop deployments.


## Notes

This plugin may have some issues on certain installations:

* Files are stored in the database (up to 16MB per file). If your database has
  size limitations, you may want to consider how to use them.

* Members can upload any filetypes and filenames, which means there is no
  protection against files with viruses, or executable files.

Before this plugin would be enabled by default, at least the latter would need
to be solved.


This plugin is part of the foodsoft package and uses the AGPL-3 license (see
foodsoft's LICENSE for the full license text).
