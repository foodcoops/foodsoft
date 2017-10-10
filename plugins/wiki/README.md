FoodsoftWiki
============

This plugin adds wiki pages to foodsoft. A new 'Wiki' menu is added next to
the 'Foodcoops' menu in the navigation bar.

This plugin is enabled by default in foodsoft, so you don't need to do anything
to install it. If you still want to, for example when it has been disabled,
add the following to foodsoft's Gemfile:

```Gemfile
# we use the git version of acts_as_versioned, so this needs to be in foodsoft's Gemfile
gem 'acts_as_versioned', git: 'https://github.com/technoweenie/acts_as_versioned.git'
gem 'foodsoft_wiki', path: 'lib/foodsoft_wiki'
```

This plugin introduces the foodcoop config option `use_wiki`, which can be set
to `false` to disable the wiki. May be useful in multicoop deployments.

This plugin is part of the foodsoft package and uses the AGPL-3 license (see
foodsoft's LICENSE for the full license text).
