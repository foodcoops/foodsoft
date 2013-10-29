$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_wiki/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_wiki"
  s.version     = FoodsoftWiki::VERSION
  s.authors     = ["wvengen"]
  s.email       = ["dev-foodsoft@willem.engen.nl"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "Wiki plugin for foodsoft."
  s.description = "Adds a wiki to foodsoft."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.15"

  s.add_development_dependency "sqlite3"
end
