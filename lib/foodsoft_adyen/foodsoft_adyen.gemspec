$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_adyen/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_adyen"
  s.version     = FoodsoftAdyen::VERSION
  s.authors     = ["wvengen"]
  s.email       = ["dev-foodsoft@willem.engen.nl"]
  s.homepage    = "https://github.com/foodcoop-adam/foodsoft"
  s.summary     = "Adyen payment plugin for foodsoft."
  s.description = "TODO: Description of FoodsoftAdyen."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency "adyen"
  s.add_dependency "jquery_mobile_rails"

  s.add_development_dependency "sqlite3"
end
