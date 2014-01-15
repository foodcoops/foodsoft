$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_vokomokum/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_vokomokum"
  s.version     = FoodsoftVokomokum::VERSION
  s.authors     = ["wvengen"]
  s.email       = ["dev-foodsoft@willem.engen.nl"]
  s.homepage    = "https://github.com/foodcoop-adam/foodsoft"
  s.summary     = "Foodsoft plugin to integrate with Vokomokum systems."
  s.description = "This plugin allows foodsoft to work with the Vokomokum ordering system."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["README.md"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency "deface", "~> 1.0.0"
end
