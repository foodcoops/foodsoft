$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_forum/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_forum"
  s.version     = FoodsoftForum::VERSION
  s.authors     = ["paroga"]
  s.email       = ["paroga@paroga.com"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "Forum plugin for foodsoft."
  s.description = "Adds simple forum to foodsoft."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_development_dependency "sqlite3"
end
