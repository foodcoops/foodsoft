ActiveSupport.on_load(:after_initialize) do
  FoodsoftMailReceiver.register MessagesMailReceiver
end
