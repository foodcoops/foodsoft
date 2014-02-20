# -*- coding: utf-8 -*-
# Configures your navigation

SimpleNavigation::Configuration.run do |navigation|

  # allow engines to add to the menu - https://gist.github.com/mjtko/4873ee0c112b6bd646f8
  engines = Rails::Engine.subclasses.map(&:instance).select { |e| e.respond_to?(:navigation) }
  # to include an engine but keep it from modifying the menu:
  #engines.reject! { |e| e.instance_of? FoodsoftMyplugin::Engine }

  navigation.items do |primary|
    primary.dom_class = 'nav'

    primary.item :dashboard_nav_item, I18n.t('navigation.dashboard'), root_path(anchor: '')

    primary.item :foodcoop, I18n.t('navigation.foodcoop'), '#', id: nil do |subnav|
      subnav.item :members, I18n.t('navigation.members'), foodcoop_users_path, id: nil
      subnav.item :workgroups, I18n.t('navigation.workgroups'), foodcoop_workgroups_path, id: nil
      subnav.item :ordergroups, I18n.t('navigation.ordergroups'), foodcoop_ordergroups_path, id: nil
      subnav.item :messages, I18n.t('navigation.messages'), messages_path, id: nil
      subnav.item :tasks, I18n.t('navigation.tasks'), tasks_path, id: nil
    end

    primary.item :orders, I18n.t('navigation.orders.title'), '#', id: nil do |subnav|
      subnav.item :ordering, I18n.t('navigation.orders.ordering'), group_orders_path, id: nil
      subnav.item :ordering_archive, I18n.t('navigation.orders.archive'), archive_group_orders_path, id: nil
      subnav.item :orders, I18n.t('navigation.orders.manage'), orders_path, if: Proc.new { current_user.role_orders? }, id: nil
    end

    primary.item :articles, I18n.t('navigation.articles.title'), '#', id: nil,
                 if: Proc.new { current_user.role_article_meta? or current_user.role_suppliers? } do |subnav|
      subnav.item :suppliers, I18n.t('navigation.articles.suppliers'), suppliers_path, id: nil
      subnav.item :stockit, I18n.t('navigation.articles.stock'), stock_articles_path, id: nil
      subnav.item :categories, I18n.t('navigation.articles.categories'), article_categories_path, id: nil
    end

    primary.item :finance, I18n.t('navigation.finances.title'), '#', id: nil, if: Proc.new { current_user.role_finance? } do |subnav|
      subnav.item :finance_home, I18n.t('navigation.finances.home'), finance_root_path
      subnav.item :accounts, I18n.t('navigation.finances.accounts'), finance_ordergroups_path, id: nil
      subnav.item :balancing, I18n.t('navigation.finances.balancing'), finance_order_index_path, id: nil
      subnav.item :invoices, I18n.t('navigation.finances.invoices'), finance_invoices_path, id: nil
    end

    primary.item :admin, I18n.t('navigation.admin.title'), '#', id: nil, if: Proc.new { current_user.role_admin? } do |subnav|
      subnav.item :admin_home, I18n.t('navigation.admin.home'), admin_root_path
      subnav.item :users, I18n.t('navigation.admin.users'), admin_users_path, id: nil
      subnav.item :ordergroups, I18n.t('navigation.admin.ordergroups'), admin_ordergroups_path, id: nil
      subnav.item :workgroups, I18n.t('navigation.admin.workgroups'), admin_workgroups_path, id: nil
    end

    engines.each { |e| e.navigation(primary, self) }
  end

end
