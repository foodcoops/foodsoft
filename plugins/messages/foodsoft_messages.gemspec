$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_messages/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_messages"
  s.version     = FoodsoftMessages::VERSION
  s.authors     = ["robwa"]
  s.email       = ["foodsoft-messages@ini.tiative.net"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "Messaging plugin for foodsoft."
  s.description = "Adds the ability to exchange messages to foodsoft."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0.0"

  s.add_development_dependency "sqlite3"
end
