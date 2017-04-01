$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_current_orders/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_current_orders"
  s.version     = FoodsoftCurrentOrders::VERSION
  s.authors     = ["wvengen"]
  s.email       = ["dev-voko@willem.engen.nl"]
  s.homepage    = "https://github.com/foodcoop-adam/foodsoft"
  s.summary     = "Quick support for working on all currently active orders in foodsoft."
  s.description = ""

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0"
end
