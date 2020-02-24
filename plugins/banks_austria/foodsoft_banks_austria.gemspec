$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foodsoft_banks_austria/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "foodsoft_banks_austria"
  s.version     = FoodsoftBanksAustria::VERSION
  s.authors     = ["paroga"]
  s.email       = ["paroga@paroga.com"]
  s.homepage    = "https://github.com/foodcoops/foodsoft"
  s.summary     = "BanksAustria plugin for foodsoft."
  s.description = "Allow SSO login via BanksAustria"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "deface", "~> 1.0"
  s.add_dependency "mechanize"
  s.add_dependency "oauth2"
end
