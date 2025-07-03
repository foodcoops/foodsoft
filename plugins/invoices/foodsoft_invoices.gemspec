$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'foodsoft_invoices/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'foodsoft_invoices'
  s.version     = FoodsoftInvoices::VERSION
  s.authors     = ['Foodsoft Team']
  s.email       = ['foodsoft@foodcoops.net']
  s.homepage    = 'https://github.com/foodcoops/foodsoft'
  s.summary     = 'Invoice plugin for foodsoft.'
  s.description = 'Adds comprehensive invoice functionality to foodsoft.'
  s.required_ruby_version = '>= 2.7'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  s.add_dependency 'rails'
  s.add_dependency 'deface', '~> 1.0'
  s.add_dependency 'prawn'
  s.add_dependency 'prawn-table'

  s.metadata['rubygems_mfa_required'] = 'true'
end
