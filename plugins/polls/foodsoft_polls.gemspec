$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_polls/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_polls"
  s.version     = FoodsoftPolls::VERSION
  s.authors     = ["paroga"]
  s.email       = ["paroga@paroga.com"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "Polls plugin for foodsoft."
  s.description = "Adds possibility to do polls with foodsoft."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0"
end
