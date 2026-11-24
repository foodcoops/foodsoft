$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'foodsoft_pickup/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'foodsoft_pickup'
  s.version     = FoodsoftPickup::VERSION
  s.authors     = ['Martin Ortbauer']
  s.email       = ['martin@villagefarmer.net']
  s.homepage    = 'https://github.com/foodcoopsat/foodsoft'
  s.summary     = 'API endpoints for pickup apps in foodsoft.'
  s.description = 'Lets a phone app list the group orders of an ordergroup that are waiting to be picked up.'
  s.license     = 'AGPL-3.0'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  s.add_dependency 'rails'
  s.add_dependency 'active_model_serializers'
  s.metadata['rubygems_mfa_required'] = 'true'
  s.required_ruby_version = '>= 3.3'
end
