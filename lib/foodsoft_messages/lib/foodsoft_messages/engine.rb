module FoodsoftMessages
  class Engine < ::Rails::Engine
    def navigation(primary, context)
      return if primary[:foodcoop].nil?
      sub_nav = primary[:foodcoop].sub_navigation
      sub_nav.items <<
        SimpleNavigation::Item.new(primary, :messages, I18n.t('navigation.messages'), context.messages_path)
      # move to right before tasks item
      if i = sub_nav.items.index(sub_nav[:tasks])
        sub_nav.items.insert(i, sub_nav.items.delete_at(-1))
      end
    end
  end
end
