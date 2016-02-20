$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_documents/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_documents"
  s.version     = FoodsoftDocuments::VERSION
  s.authors     = ["paroga"]
  s.email       = ["paroga@paroga.com"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "Documents plugin for foodsoft."
  s.description = "Adds simple document management to foodsoft."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0.0"
end
