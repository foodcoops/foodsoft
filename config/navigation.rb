# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  navigation.items do |primary|
    primary.dom_class = 'nav'

    primary.item :foodcoop, 'Foodcoop', '#' do |subnav|
      subnav.item :members, 'Mitglieder', foodcoop_users_path, id: nil
      subnav.item :workgroups, 'Arbeitsgruppen', foodcoop_workgroups_path, id: nil
      subnav.item :ordergroups, 'Bestellgruppen', foodcoop_ordergroups_path, id: nil
      subnav.item :messages, 'Nachrichten', messages_path, id: nil
      subnav.item :tasks, 'Aufgaben', tasks_path, id: nil
    end

    primary.item :wiki, 'Wiki', '#' do |subnav|
      subnav.item :wiki_home, 'Startseite', wiki_path, id: nil
      subnav.item :all_pages, 'Alle Seiten', all_pages_path, id: nil
    end

    primary.item :orders, 'Bestellungen', '#' do |subnav|
      subnav.item :ordering, 'Bestellen!', group_orders_path, id: nil
      subnav.item :ordering_archive, 'Meine Bestellungen', archive_group_orders_path, id: nil
      subnav.item :orders, 'Bestellverwaltung', orders_path, if: Proc.new { current_user.role_orders? }, id: nil
    end

    primary.item :articles, 'Artikel', '#',
                 if: Proc.new { current_user.role_article_meta? or current_user.role_suppliers? } do |subnav|
      subnav.item :suppliers, 'Lieferanten/Artikel', suppliers_path, id: nil
      subnav.item :stockit, 'Lager', stock_articles_path, id: nil
      subnav.item :categories, 'Kategorien', article_categories_path, id: nil
    end

    primary.item :finance, 'Finanzen', '#', if: Proc.new { current_user.role_finance? } do |subnav|
      subnav.item :accounts, 'Konten verwalten', finance_ordergroups_path, id: nil
      subnav.item :balancing, 'Bestellungen abrechnen', finance_balancing_path, id: nil
      subnav.item :invoices, 'Rechnungen', finance_invoices_path, id: nil
    end

    primary.item :admin, 'Administration', '#', if: Proc.new { current_user.role_admin? } do |subnav|
      subnav.item :users, 'Benutzerinnen', admin_users_path, id: nil
      subnav.item :ordergroups, 'Bestellgruppen', admin_ordergroups_path, id: nil
      subnav.item :workgroups, 'Arbeitsgruppen', admin_workgroups_path, id: nil
    end

    primary.item :divider, '', '#', class: 'divider'

    if FoodsoftConfig[:homepage]
      primary.item :homepage, FoodsoftConfig[:name], FoodsoftConfig[:homepage]
    end
    primary.item :help, 'Hilfe', 'https://github.com/bennibu/foodsoft/wiki/Doku', id: nil
    primary.item :feedback, 'Feedback', 'new_feedback_path', title: "Fehler gefunden? Vorschlag? Idee? Kritik?", id: nil
    primary.item :nick, current_user.nick, '#' do |subnav|
      subnav.item :edit_profile, 'Profil bearbeiten', my_profile_path, title: 'Profil bearbeiten', id: nil
      subnav.item :logout, 'Abmelden', logout_path, id: nil
    end
  end

end
