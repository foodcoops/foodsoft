# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |primary|
    primary.dom_class = 'nav'

    primary.item :dashboard_nav_item, 'Dashboard', root_path(anchor: '')

    primary.item :foodcoop, 'Foodcoop', '#', id: nil do |subnav|
      subnav.item :members, 'Mitglieder', foodcoop_users_path, id: nil
      subnav.item :workgroups, 'Arbeitsgruppen', foodcoop_workgroups_path, id: nil
      subnav.item :ordergroups, 'Bestellgruppen', foodcoop_ordergroups_path, id: nil
      subnav.item :messages, 'Nachrichten', messages_path, id: nil
      subnav.item :tasks, 'Aufgaben', tasks_path, id: nil
    end

    primary.item :wiki, 'Wiki', '#', id: nil do |subnav|
      subnav.item :wiki_home, 'Startseite', wiki_path, id: nil
      subnav.item :all_pages, 'Alle Seiten', all_pages_path, id: nil
    end

    primary.item :orders, 'Bestellungen', '#', id: nil do |subnav|
      subnav.item :ordering, 'Bestellen!', group_orders_path, id: nil
      subnav.item :ordering_archive, 'Meine Bestellungen', archive_group_orders_path, id: nil
      subnav.item :orders, 'Bestellverwaltung', orders_path, if: Proc.new { current_user.role_orders? }, id: nil
    end

    primary.item :articles, 'Artikel', '#', id: nil,
                 if: Proc.new { current_user.role_article_meta? or current_user.role_suppliers? } do |subnav|
      subnav.item :suppliers, 'Lieferanten/Artikel', suppliers_path, id: nil
      subnav.item :stockit, 'Lager', stock_articles_path, id: nil
      subnav.item :categories, 'Kategorien', article_categories_path, id: nil
    end

    primary.item :finance, 'Finanzen', '#', id: nil, if: Proc.new { current_user.role_finance? } do |subnav|
      subnav.item :finance_home, 'Übersicht', finance_root_path
      subnav.item :accounts, 'Konten verwalten', finance_ordergroups_path, id: nil
      subnav.item :balancing, 'Bestellungen abrechnen', finance_order_index_path, id: nil
      subnav.item :invoices, 'Rechnungen', finance_invoices_path, id: nil
    end

    primary.item :admin, 'Administration', '#', id: nil, if: Proc.new { current_user.role_admin? } do |subnav|
      subnav.item :admin_home, 'Übersicht', admin_root_path
      subnav.item :users, 'Benutzerinnen', admin_users_path, id: nil
      subnav.item :ordergroups, 'Bestellgruppen', admin_ordergroups_path, id: nil
      subnav.item :workgroups, 'Arbeitsgruppen', admin_workgroups_path, id: nil
    end
  end

end
