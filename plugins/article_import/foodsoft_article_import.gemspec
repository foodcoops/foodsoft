# frozen_string_literal: true

require File.expand_path('lib/foodsoft_article_import/version', __dir__)
Gem::Specification.new do |spec|
  spec.name                  = 'foodsoft_article_import'
  spec.version               = FoodsoftArticleImport::VERSION

  spec.authors               = ['Philipp Feuerbach, Wvengen']
  spec.email                 = ['pf@pragma-shift.net']

  spec.summary               = 'Import Files for Foodcoops for Ruby on Rails'
  spec.description           = 'This gem allows to import files containing article information to foodsoft. It was created to avoid code redundancy and is based on the sharedlist application https://github.com/foodcoops/sharedlists.'
  spec.homepage              = 'https://gitea.com/viehlieb/foodsoft-article_import'

  spec.license               = 'MIT'
  spec.platform              = Gem::Platform::RUBY

  spec.required_ruby_version = '>= 2.7.0'

  spec.files = Dir['README.md', 'LICENSE',
                   'CHANGELOG.md', 'lib/**/*.rb',
                   'lib/foodsoft_article_import/bnn.rb',
                   'lib/foodsoft_article_import.rb',
                   'lib/**/*.rake',
                   'foodsoft_article_import.gemspec', '.github/*.md',
                   'Gemfile', 'Rakefile']
  spec.extra_rdoc_files = ['README.md']

  spec.add_dependency 'roo', '~> 2.9.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
