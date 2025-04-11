# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies
  .autoload_paths
  .delete(Rails.root.join('app/controllers/concerns').to_s)
