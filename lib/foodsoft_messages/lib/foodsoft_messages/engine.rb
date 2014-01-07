module FoodsoftMessages
  class Engine < ::Rails::Engine
    def navigation(primary, context)
      item = SimpleNavigation::Item.new(primary, :messages, I18n.t('navigation.messages'), context.messages_path)
      sub_nav = primary[:foodcoop].sub_navigation
      # display right before tasks item
      tasks_index = sub_nav.items.index(sub_nav[:tasks])
      sub_nav.items.insert(tasks_index, item)
    end
  end
end
