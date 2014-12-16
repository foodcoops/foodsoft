$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_uservoice/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_uservoice"
  s.version     = FoodsoftUservoice::VERSION
  s.authors     = ["wvengen"]
  s.email       = ["dev-foodsoft@willem.engen.nl"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "Uservoice plugin for foodsoft."
  s.description = "Adds a uservoice feedback button to foodsoft."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["README.md"]

  s.add_dependency "rails"
  s.add_dependency "content_for_in_controllers"
end
