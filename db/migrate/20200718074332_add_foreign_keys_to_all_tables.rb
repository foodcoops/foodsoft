class AddForeignKeysToAllTables < ActiveRecord::Migration[5.2]
  def change
    # article_prices
    add_foreign_key :article_prices, :articles

    # articles
    add_foreign_key :articles, :suppliers
    add_foreign_key :articles, :article_categories

    # assignments
    add_foreign_key :assignments, :users
    add_foreign_key :assignments, :tasks

    # bank_transactions
    add_foreign_key :bank_transactions, :bank_accounts
    add_foreign_key :bank_transactions, :financial_links

    # stock_events
    add_foreign_key :stock_events, :suppliers
    add_foreign_key :stock_events, :invoices

    # documents
    add_foreign_key :documents, :users, column: :created_by_user_id
    # parent_id?

    # financial_transaction_types
    add_foreign_key :financial_transaction_types, :financial_transaction_classes

    # financial_transactions
    add_foreign_key :financial_transactions, :groups, column: :ordergroup_id
    add_foreign_key :financial_transactions, :users
    add_foreign_key :financial_transactions, :financial_links
    add_foreign_key :financial_transactions, :financial_transaction_types
    add_foreign_key :financial_transactions, :financial_transactions, column: :reverts_id
    add_foreign_key :financial_transactions, :group_orders

    # group_order_article_quantities
    add_foreign_key :group_order_article_quantities, :group_order_articles

    # group_order_articles
    add_foreign_key :group_order_articles, :group_orders
    add_foreign_key :group_order_articles, :order_articles

    # group_orders
    add_foreign_key :group_orders, :groups, column: :ordergroup_id
    add_foreign_key :group_orders, :orders
    add_foreign_key :group_orders, :users, column: :updated_by_user_id

    # invites
    add_foreign_key :invites, :groups
    add_foreign_key :invites, :users

    # invoices
    add_foreign_key :invoices, :suppliers
    add_foreign_key :invoices, :users, column: :created_by_user_id
    add_foreign_key :invoices, :financial_links

    # links
    # workgroup_id?

    # memberships
    add_foreign_key :memberships, :groups
    add_foreign_key :memberships, :users

    # message_recipients
    add_foreign_key :message_recipients, :messages
    add_foreign_key :message_recipients, :users

    # messages
    add_foreign_key :messages, :users, column: :sender_id
    add_foreign_key :messages, :messages, column: :reply_to
    add_foreign_key :messages, :groups

    # oauth_access_grants
    # resource_owner_id -> users ?

    # oauth_access_tokens
    # resource_owner_id -> users ?

    # order_articles
    add_foreign_key :order_articles, :orders
    add_foreign_key :order_articles, :articles
    add_foreign_key :order_articles, :article_prices

    # order_comments
    add_foreign_key :order_comments, :orders
    add_foreign_key :order_comments, :users

    # orders
    add_foreign_key :orders, :suppliers
    add_foreign_key :orders, :users, column: :updated_by_user_id
    add_foreign_key :orders, :users, column: :created_by_user_id
    add_foreign_key :orders, :invoices

    # page_versions
    add_foreign_key :page_versions, :pages
    add_foreign_key :page_versions, :pages, column: :parent_id

    # pages
    add_foreign_key :pages, :pages, column: :parent_id

    # poll_choices
    add_foreign_key :poll_choices, :poll_votes

    # poll_votes
    add_foreign_key :poll_votes, :polls
    add_foreign_key :poll_votes, :users
    add_foreign_key :poll_votes, :groups, column: :ordergroup_id

    # polls
    add_foreign_key :polls, :users, column: :created_by_user_id

    # printer_job_updates
    add_foreign_key :printer_job_updates, :printer_jobs

    # printer_jobs
    add_foreign_key :printer_jobs, :orders
    add_foreign_key :printer_jobs, :users, column: :created_by_user_id
    add_foreign_key :printer_jobs, :users, column: :finished_by_user_id

    # stock_changes
    add_foreign_key :stock_changes, :stock_events
    add_foreign_key :stock_changes, :orders
    add_foreign_key :stock_changes, :articles, column: :stock_article_id

    # supplier_categories
    add_foreign_key :supplier_categories, :financial_transaction_classes

    # suppliers
    add_foreign_key :suppliers, :supplier_categories

    # tasks
    add_foreign_key :tasks, :groups, column: :workgroup_id
    add_foreign_key :tasks, :groups, column: :periodic_task_group_id
    add_foreign_key :tasks, :users, column: :created_by_user_id
  end
end

