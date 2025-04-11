Rails.application.config.to_prepare do
  FoodsoftMailReceiver.register BounceMailReceiver
end
