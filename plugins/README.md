# Plugins

## Plugin maintenance

Rules about maintaining the plugins in this folder:

- Any plugins [activated by default in the Gemfile](https://github.com/foodcoops/foodsoft/blob/master/Gemfile#L69) are maintained by the core developers.
- Any plugins _not_ activated by default, should have a list of plugin maintainers in its README, serving the following purpose:
    * Should there be an update/change implemented by the core team in the future, that causes the plugin to malfunction or its unit tests to fail, the core team will try to contact those plugin maintainers and ask them, if and how those issues can be resolved.
    * If the plugin maintainers are then no longer active or don't have the ressources to fix the issues, the core developers may decide to simply remove the plugin.
