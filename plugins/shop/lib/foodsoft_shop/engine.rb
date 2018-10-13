require 'glyphicons'

module FoodsoftShop
  class Engine < ::Rails::Engine
    initializer 'foodsoft_shop.assets.precompile' do |app|
      # add foodsoft-shop javascript bundle
      app.config.assets.precompile << 'foodsoft_shop/bundle.js'
      # include bootstrap (Foodsoft still uses bootstrap 2)
      app.config.assets.precompile << 'foodsoft_shop/application.css'
    end
  end
end
