class ApplicationJob < ActiveJob::Base
  def perform(foodcoop, *args)
    FoodsoftConfig.select_foodcoop(foodcoop) if FoodsoftConfig[:multi_coop_install]
    execute *args
  end

  def self.perform_later(*args)
    super FoodsoftConfig.scope, *args
  end
end
