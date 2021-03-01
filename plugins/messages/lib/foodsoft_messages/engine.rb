module FoodsoftMessages
  class Engine < ::Rails::Engine
    def navigation(primary, context)
      return unless FoodsoftMessages.enabled?

      unless primary[:foodcoop].nil?
        sub_nav = primary[:foodcoop].sub_navigation
        sub_nav.items <<
          SimpleNavigation::Item.new(primary, :messages, I18n.t('navigation.messages'), context.message_threads_path)
        # move to right before tasks item
        if i = sub_nav.items.index(sub_nav[:tasks])
          sub_nav.items.insert(i, sub_nav.items.delete_at(-1))
        end
      end
      unless primary[:admin].nil?
        sub_nav = primary[:admin].sub_navigation
        sub_nav.items <<
          SimpleNavigation::Item.new(primary, :messagegroups, I18n.t('navigation.admin.messagegroups'), context.admin_messagegroups_path)
        # move to right before config item
        if i = sub_nav.items.index(sub_nav[:config])
          sub_nav.items.insert(i, sub_nav.items.delete_at(-1))
        end
      end
    end

    def default_foodsoft_config(cfg)
      cfg[:use_messages] = true
    end
  end
end
