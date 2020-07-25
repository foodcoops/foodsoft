# Initial load the default config and database from rails environment
# See config/app_config.yml for further details
# Load Config, start by selecting defaults via current environment
require 'foodsoft_config'
FoodsoftConfig.init
FoodsoftConfig.init_mailing
