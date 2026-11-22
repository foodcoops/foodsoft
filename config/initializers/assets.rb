# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[application_legacy.js jquery.min.js trix-editor-overrides.js]

# Add registered assets after all plugins have been initialized
Rails.application.config.after_initialize do
  Rails.application.config.assets.precompile += Foodsoft::AssetRegistry.precompile_assets
end
