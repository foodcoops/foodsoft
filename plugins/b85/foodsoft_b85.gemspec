$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'foodsoft_b85/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'foodsoft_b85'
  s.version     = FoodsoftB85::VERSION
  s.authors     = ['Foodsoft Team']
  s.email       = ['foodsoft@foodcoops.net']
  s.homepage    = 'https://github.com/foodcoops/foodsoft'
  s.summary     = 'B85 order method plugin for foodsoft.'
  s.description = 'Adds B85 order method (Biofakt B85 Mailbox Order Format) to foodsoft.'
  s.required_ruby_version = '>= 2.7.0'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  s.add_dependency 'rails'
  s.metadata['rubygems_mfa_required'] = 'true'
end
