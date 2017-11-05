require 'foodsoft_polls/engine'

module FoodsoftPolls
  # Return whether the polls are used or not.
  # Enabled by default in {FoodsoftConfig} since it used to be part of the foodsoft core.
  def self.enabled?
    FoodsoftConfig[:use_polls]
  end
end
