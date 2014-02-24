$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_signup/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_signup"
  s.version     = FoodsoftSignup::VERSION
  s.authors     = ["wvengen"]
  s.email       = ["dev-foodsoft@willem.engen.nl"]
  s.homepage    = "https://github.com/foodcoop-adam/foodsoft"
  s.summary     = "Foodsoft plugin to allow prospective members to signup themselves."
  s.description = "This plugin allows prospective members to create a new foodsoft account (and ordergroup). Only when their ordergroup is approved by an administrator, can they order (this is configurable)."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["README.md"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0.0"
end
