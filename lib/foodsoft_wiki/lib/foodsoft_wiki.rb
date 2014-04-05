require 'wikicloth'
require 'acts_as_versioned'
require 'diffy'
require 'content_for_in_controllers'
require 'foodsoft_wiki/engine'

module FoodsoftWiki
  # Return whether the wiki is used or not.
  # Enabled by default since it used to be part of the foodsoft core.
  def self.enabled?
    FoodsoftConfig[:use_wiki] != false
  end
end
