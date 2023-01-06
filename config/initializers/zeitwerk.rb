ActiveSupport::Dependencies
  .autoload_paths
  .delete("#{Rails.root}/app/controllers/concerns")
