$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'foodsoft_links/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'foodsoft_links'
  s.version     = FoodsoftLinks::VERSION
  s.authors     = ['paroga']
  s.email       = ['paroga@paroga.com']
  s.homepage    = 'https://github.com/foodcoops/foodsoft'
  s.summary     = 'Links plugin for foodsoft.'
  s.description = 'Adds simple link management to foodsoft.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  s.add_dependency 'rails'
  s.add_dependency 'deface', '~> 1.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
