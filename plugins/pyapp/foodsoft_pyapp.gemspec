require_relative "lib/foodsoft_pyapp/version"

Gem::Specification.new do |spec|
  spec.name        = "foodsoft_pyapp"
  spec.version     = FoodsoftPyapp::VERSION
  spec.authors     = [""]
  spec.email       = [""]
  spec.homepage    = "https://github.com/mortbauer/"
  spec.summary     = "A python layer on top of foodsoft"
  spec.description = "A moder python vue layer on top of rails"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "http://villagefarmer.net"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mortbauer/pyfoodsoft"
  spec.metadata["changelog_uri"] = "https://github.com/mortbauer/pyfoodsoft/Changelog.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.8"
end
