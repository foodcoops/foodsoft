module FoodsoftLinks
  class Engine < ::Rails::Engine
    def navigation(primary, context)
      primary.item :links, I18n.t('navigation.links'), '#', if: proc { visble_links(context).any? } do |subnav|
        visble_links(context).each do |link|
          subnav.item link.id, link.name, context.link_path(link)
        end
      end
      # move to left before admin item
      if i = primary.items.index(primary[:admin])
        primary.items.insert(i, primary.items.delete_at(-1))
      end

      return if primary[:admin].nil?

      sub_nav = primary[:admin].sub_navigation
      sub_nav.items <<
        SimpleNavigation::Item.new(primary, :links, I18n.t('navigation.admin.links'), context.admin_links_path)
      # move to right before config item
      return unless i = sub_nav.items.index(sub_nav[:config])

      sub_nav.items.insert(i, sub_nav.items.delete_at(-1))
    end

    def visble_links(context)
      ret = Link.ordered

      current_user = context.current_user
      unless current_user.role_admin?
        workgroups = current_user.workgroups.map(&:id)
        ret = ret.where(workgroup: [nil] + workgroups)
      end

      ret
    end
  end
end
