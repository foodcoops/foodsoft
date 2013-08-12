# -*- coding: utf-8 -*-
# Configures your navigation

SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |primary|
    primary.dom_class = 'nav'

    #primary.item :dashboard_nav_item, I18n.t('navigation.dashboard'), root_path(anchor: '')

    primary.item :orders, I18n.t('navigation.orders.title'), orders_path, if: Proc.new { current_user.role_orders? }, id: nil
    # I18n.t('navigation.orders.manage')

    primary.item :suppliers, 'Products', suppliers_path, id: nil
    primary.item :balancing, 'Receive', finance_order_index_path, id: nil, if: Proc.new { current_user.role_finance? }
    primary.item :accounts, 'Member payments', finance_ordergroups_path, id: nil, if: Proc.new { current_user.role_finance? }

    #primary.item :finance, I18n.t('navigation.finances.title'), '#', id: nil, if: Proc.new { current_user.role_finance? } do |subnav|
      #subnav.item :finance_home, I18n.t('navigation.finances.home'), finance_root_path
      #subnav.item :accounts, I18n.t('navigation.finances.accounts'), finance_ordergroups_path, id: nil
      #subnav.item :balancing, I18n.t('navigation.finances.balancing'), finance_order_index_path, id: nil
      #subnav.item :invoices, I18n.t('navigation.finances.invoices'), finance_invoices_path, id: nil
    #end

    primary.item :admin, 'Membership', '#', id: nil, if: Proc.new { current_user.role_admin? } do |subnav|
      subnav.item :admin_home, I18n.t('navigation.admin.home'), admin_root_path
      subnav.item :users, I18n.t('navigation.admin.users'), admin_users_path, id: nil
      subnav.item :ordergroups, I18n.t('navigation.admin.ordergroups'), admin_ordergroups_path, id: nil
      subnav.item :workgroups, I18n.t('navigation.admin.workgroups'), admin_workgroups_path, id: nil
   end

    primary.item :others, 'Other', '#', id: nil  do |subnav|
      subnav.item :categories, I18n.t('navigation.articles.categories'), article_categories_path, id: nil, if: Proc.new { current_user.role_admin? }
      subnav.item :finance_home, 'Financial overview', finance_root_path, if: Proc.new { current_user.role_finance? }
      subnav.item :invoices, I18n.t('navigation.finances.invoices'), finance_invoices_path, id: nil, if: Proc.new { current_user.role_finance? }
    end
  end

end
