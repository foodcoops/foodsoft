$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'foodsoft_mollie/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'foodsoft_mollie'
  s.version     = FoodsoftMollie::VERSION
  s.authors     = %w[wvengen yksflip]
  s.email       = ['dev-foodsoft@willem.engen.nl', 'foodsoft@yksflip.de']
  s.homepage    = 'https://github.com/foodcoops/foodsoft'
  s.summary     = 'Mollie payment plugin for foodsoft.'
  s.description = 'Integration with Mollie payments.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails'
  s.add_dependency 'mollie-api-ruby'
  s.metadata['rubygems_mfa_required'] = 'true'
  s.required_ruby_version = '>= 2.7'
end
