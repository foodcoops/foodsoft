module FoodsoftForum
  class Engine < ::Rails::Engine
    def navigation(primary, context)
      return unless FoodsoftForum.enabled?
      primary.item :forum, I18n.t('navigation.forum'), '/f/forums', id: nil do |subnav|
        for category in  Forem::Category.all
          subnav.item :forem_category, category.name, '/f/forums/categories/' + category.name.downcase, id: nil
        end
      end
      # move this last added item to just after the foodcoop menu
      if i = primary.items.index(primary[:foodcoop])
        primary.items.insert(i+1, primary.items.delete_at(-1))
      end
    end

    def default_foodsoft_config(cfg)
      cfg[:use_forum] = true
    end
  end
end
