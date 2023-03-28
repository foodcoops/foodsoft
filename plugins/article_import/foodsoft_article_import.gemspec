$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_article_import/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_article_import"
  s.version     = FoodsoftArticleImport::VERSION
  s.authors     = ["viehlieb"]
  s.email       = ["foodsoft@local-it.org"]
  s.summary     = "Manages manual article import from file. File Formats supported are: foodsoft file(csv), bnn files (.bnn) and odin files (xml)"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0"
  s.add_dependency 'roo', '~> 2.9.0'
  s.add_development_dependency 'simplecov'
end
