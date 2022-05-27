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

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency 'wikicloth'
  s.add_dependency 'twitter-text', '~> 1.14' # wikicloth doesn't support version 2
  s.add_dependency 'acts_as_versioned' # need git version, make sure that is included in foodsoft's Gemfile
  s.add_dependency "deface", "~> 1.0"
  s.add_dependency 'diffy'
  s.add_dependency 'content_for_in_controllers'
  s.add_development_dependency "sqlite3"
end
