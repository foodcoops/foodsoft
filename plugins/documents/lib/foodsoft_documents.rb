require 'foodsoft_documents/engine'

module FoodsoftDocuments
  # Return whether the documents are used or not.
  # Enabled by default in {FoodsoftConfig} since it used to be part of the foodsoft core.
  def self.enabled?
    FoodsoftConfig[:use_documents]
  end
end
