module FoodsoftLinks
  class Engine < ::Rails::Engine
    def navigation(primary, context)
      primary.item :links, I18n.t('navigation.links'), '#', if: Proc.new { visble_links(context).any? }  do |subnav|
        visble_links(context).each do |link|
          subnav.item link.id, link.name, context.link_path(link)
        end
      end
      # move to left before admin item
      if i = primary.items.index(primary[:admin])
        primary.items.insert(i, primary.items.delete_at(-1))
      end
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
