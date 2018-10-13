$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_shop/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_shop"
  s.version     = FoodsoftShop::VERSION
  s.authors     = ["wvengen"]
  s.email       = ["dev-foodsoft@willem.engen.nl"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "An alternative member ordering interface for Foodsoft"
  s.description = "Replaces the member ordering screens with a single ordering application."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["README.md"]

  s.add_dependency "rails"
  s.add_dependency "glyphicons"
end
