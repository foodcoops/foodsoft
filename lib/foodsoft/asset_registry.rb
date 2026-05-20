# frozen_string_literal: true

module Foodsoft
  class AssetRegistry
    class << self
      def stylesheets
        @stylesheets ||= Set.new(['application'])
      end

      def javascripts
        @javascripts ||= Set.new(['application_legacy'])
      end

      def register_stylesheet(name)
        stylesheets.add(name)
      end

      def register_javascript(name)
        javascripts.add(name)
      end

      def precompile_assets
        (stylesheets.map { |s| "#{s}.css" } + javascripts.map { |j| "#{j}.js" }).to_a
      end
    end
  end
end
