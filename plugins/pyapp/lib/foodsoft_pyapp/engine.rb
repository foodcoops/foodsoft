module FoodsoftPyapp
  class Engine < ::Rails::Engine
    def navigation(primary, ctx)
      return unless FoodsoftPyapp.enabled?
      return if primary[:foodcoop].nil?

      primary.item :planned_tasks, I18n.t('navigation.planned_tasks.title'), '#', id: nil do |subnav|
        subnav.item :planned_task_types, I18n.t('navigation.planned_tasks.all'), "/#{FoodsoftConfig.scope}/app/"
        visble_planned_tasks(ctx).each do |task|
          subnav.item task.id, task.name, "/#{FoodsoftConfig.scope}/app/planned-tasks/?task_type=#{task.name}"
        end
        # subnav.item :all_pages, I18n.t('navigation.wiki.all_pages'), ctx.all_pages_path, id: nil
      end
      # move this last added item to just after the foodcoop menu
      return unless i = primary.items.index(primary[:foodcoop])

      primary.items.insert(i + 2, primary.items.delete_at(-1))

      # also add admin menu
      return if primary[:admin].nil?
      sub_nav = primary[:admin].sub_navigation
      sub_nav.items <<
        SimpleNavigation::Item.new(primary, :links, I18n.t('navigation.admin.tasks'), "/#{FoodsoftConfig.scope}/app/admin/planned-tasks/")
      # move to right before config item
      return unless i = sub_nav.items.index(sub_nav[:config])

      sub_nav.items.insert(i, sub_nav.items.delete_at(-1)) 
    end

    def default_foodsoft_config(cfg)
      cfg[:use_pyapp] = false
    end

    def visble_planned_tasks(ctx)
      ret = PlannedTaskType.all

      # current_user = ctx.current_user
      # unless current_user.role_admin?
      #   workgroups = current_user.workgroups.map(&:id)
      #   ret = ret.where(workgroup: [nil] + workgroups)
      # end

      ret
    end

  end
end

