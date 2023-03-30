# frozen_string_literal: true

module TestHelper
  ENV["FOODSOFT_APP_CONFIG"] = "plugins/article_import/spec/app_config.yml"
end

RSpec.configure do |config|
  config.include TestHelper, :type => :feature
end
