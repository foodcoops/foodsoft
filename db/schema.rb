# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_03_06_141647) do
  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "article_categories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "description"
    t.index ["name"], name: "index_article_categories_on_name", unique: true
  end

  create_table "article_prices", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "article_id", null: false
    t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "tax", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "deposit", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "unit_quantity"
    t.datetime "created_at", precision: nil
    t.index ["article_id"], name: "index_article_prices_on_article_id"
  end

  create_table "articles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "supplier_id", default: 0, null: false
    t.integer "article_category_id", default: 0, null: false
    t.string "unit", default: "", null: false
    t.string "note"
    t.boolean "availability", default: true, null: false
    t.string "manufacturer"
    t.string "origin"
    t.datetime "shared_updated_on", precision: nil
    t.decimal "price", precision: 8, scale: 2
    t.float "tax"
    t.decimal "deposit", precision: 8, scale: 2, default: "0.0"
    t.integer "unit_quantity", default: 1, null: false
    t.string "order_number"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.string "type"
    t.integer "quantity", default: 0
    t.index ["article_category_id"], name: "index_articles_on_article_category_id"
    t.index ["name", "supplier_id"], name: "index_articles_on_name_and_supplier_id"
    t.index ["supplier_id"], name: "index_articles_on_supplier_id"
    t.index ["type"], name: "index_articles_on_type"
  end

  create_table "assignments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "user_id", default: 0, null: false
    t.integer "task_id", default: 0, null: false
    t.boolean "accepted", default: false
    t.index ["user_id", "task_id"], name: "index_assignments_on_user_id_and_task_id", unique: true
  end

  create_table "bank_accounts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "iban"
    t.string "description"
    t.decimal "balance", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "last_import", precision: nil
    t.string "import_continuation_point"
    t.integer "bank_gateway_id"
  end

  create_table "bank_gateways", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "url", null: false
    t.string "authorization"
    t.integer "unattended_user_id"
  end

  create_table "bank_transactions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "bank_account_id", null: false
    t.string "external_id"
    t.date "date"
    t.decimal "amount", precision: 8, scale: 2, null: false
    t.string "iban"
    t.string "reference"
    t.text "text"
    t.text "receipt"
    t.binary "image", size: :medium
    t.integer "financial_link_id"
    t.index ["financial_link_id"], name: "index_bank_transactions_on_financial_link_id"
  end

  create_table "documents", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.integer "created_by_user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "parent_id"
    t.boolean "folder", default: false, null: false
    t.index ["parent_id"], name: "index_documents_on_parent_id"
  end

  create_table "financial_links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "note"
  end

  create_table "financial_transaction_classes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "ignore_for_account_balance", default: false, null: false
  end

  create_table "financial_transaction_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "financial_transaction_class_id", null: false
    t.string "name_short"
    t.integer "bank_account_id"
    t.index ["name_short"], name: "index_financial_transaction_types_on_name_short"
  end

  create_table "financial_transactions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "ordergroup_id"
    t.decimal "amount", precision: 8, scale: 2, default: "0.0", null: false
    t.text "note", null: false
    t.integer "user_id", default: 0, null: false
    t.datetime "created_on", precision: nil, null: false
    t.integer "financial_transaction_type_id", null: false
    t.integer "financial_link_id"
    t.integer "reverts_id"
    t.integer "group_order_id"
    t.index ["ordergroup_id"], name: "index_financial_transactions_on_ordergroup_id"
    t.index ["reverts_id"], name: "index_financial_transactions_on_reverts_id", unique: true
  end

  create_table "group_order_article_quantities", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "group_order_article_id", default: 0, null: false
    t.integer "quantity", default: 0
    t.integer "tolerance", default: 0
    t.datetime "created_on", precision: nil, null: false
    t.index ["group_order_article_id"], name: "index_group_order_article_quantities_on_group_order_article_id"
  end

  create_table "group_order_articles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "group_order_id", default: 0, null: false
    t.integer "order_article_id", default: 0, null: false
    t.integer "quantity", default: 0, null: false
    t.integer "tolerance", default: 0, null: false
    t.datetime "updated_on", precision: nil, null: false
    t.decimal "result", precision: 8, scale: 3
    t.decimal "result_computed", precision: 8, scale: 3
    t.index ["group_order_id", "order_article_id"], name: "goa_index", unique: true
    t.index ["group_order_id"], name: "index_group_order_articles_on_group_order_id"
    t.index ["order_article_id"], name: "index_group_order_articles_on_order_article_id"
  end

  create_table "group_orders", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "ordergroup_id"
    t.integer "order_id", default: 0, null: false
    t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "updated_on", precision: nil, null: false
    t.integer "updated_by_user_id"
    t.decimal "transport", precision: 8, scale: 2
    t.index ["order_id"], name: "index_group_orders_on_order_id"
    t.index ["ordergroup_id", "order_id"], name: "index_group_orders_on_ordergroup_id_and_order_id", unique: true
    t.index ["ordergroup_id"], name: "index_group_orders_on_ordergroup_id"
  end

  create_table "groups", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "type", default: "", null: false
    t.string "name", default: "", null: false
    t.string "description"
    t.decimal "account_balance", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_on", precision: nil, null: false
    t.boolean "role_admin", default: false, null: false
    t.boolean "role_suppliers", default: false, null: false
    t.boolean "role_article_meta", default: false, null: false
    t.boolean "role_finance", default: false, null: false
    t.boolean "role_orders", default: false, null: false
    t.datetime "deleted_at", precision: nil
    t.string "contact_person"
    t.string "contact_phone"
    t.string "contact_address"
    t.text "stats"
    t.integer "next_weekly_tasks_number", default: 8
    t.boolean "ignore_apple_restriction", default: false
    t.date "break_start"
    t.date "break_end"
    t.boolean "role_invoices", default: false, null: false
    t.boolean "role_pickups", default: false, null: false
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "invites", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "token", default: "", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.integer "group_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.string "email", default: "", null: false
    t.index ["token"], name: "index_invites_on_token"
  end

  create_table "invoices", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "supplier_id"
    t.string "number"
    t.date "date"
    t.date "paid_on"
    t.text "note"
    t.decimal "amount", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "deposit", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "deposit_credit", precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "created_by_user_id"
    t.integer "financial_link_id"
    t.index ["supplier_id"], name: "index_invoices_on_supplier_id"
  end

  create_table "links", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "url", null: false
    t.integer "workgroup_id"
    t.boolean "indirect", default: false, null: false
    t.string "authorization"
  end

  create_table "mail_delivery_status", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "email", null: false
    t.string "message", null: false
    t.string "attachment_mime"
    t.binary "attachment_data", size: :long
    t.index ["email"], name: "index_mail_delivery_status_on_email"
  end

  create_table "memberships", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "group_id", default: 0, null: false
    t.integer "user_id", default: 0, null: false
    t.index ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true
  end

  create_table "message_recipients", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "message_id", null: false
    t.integer "user_id", null: false
    t.integer "email_state", default: 0, null: false
    t.datetime "read_at", precision: nil
    t.index ["message_id"], name: "index_message_recipients_on_message_id"
    t.index ["user_id", "read_at"], name: "index_message_recipients_on_user_id_and_read_at"
  end

  create_table "messages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "sender_id"
    t.string "subject", null: false
    t.boolean "private", default: false
    t.datetime "created_at", precision: nil
    t.integer "reply_to"
    t.integer "group_id"
    t.string "salt"
    t.binary "received_email", size: :medium
  end

  create_table "oauth_access_grants", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "confidential", default: true, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "order_articles", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "order_id", default: 0, null: false
    t.integer "article_id", default: 0, null: false
    t.integer "quantity", default: 0, null: false
    t.integer "tolerance", default: 0, null: false
    t.integer "units_to_order", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.integer "article_price_id"
    t.decimal "units_billed", precision: 8, scale: 3
    t.decimal "units_received", precision: 8, scale: 3
    t.index ["order_id", "article_id"], name: "index_order_articles_on_order_id_and_article_id", unique: true
    t.index ["order_id"], name: "index_order_articles_on_order_id"
  end

  create_table "order_comments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "order_id"
    t.integer "user_id"
    t.text "text"
    t.datetime "created_at", precision: nil
    t.index ["order_id"], name: "index_order_comments_on_order_id"
  end

  create_table "orders", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "supplier_id"
    t.text "note"
    t.datetime "starts", precision: nil
    t.datetime "ends", precision: nil
    t.string "state", default: "open"
    t.integer "lock_version", default: 0, null: false
    t.integer "updated_by_user_id"
    t.decimal "foodcoop_result", precision: 8, scale: 2
    t.integer "created_by_user_id"
    t.datetime "boxfill", precision: nil
    t.integer "invoice_id"
    t.date "pickup"
    t.datetime "last_sent_mail", precision: nil
    t.integer "end_action", default: 0, null: false
    t.decimal "transport", precision: 8, scale: 2
    t.index ["state"], name: "index_orders_on_state"
  end

  create_table "page_versions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "page_id"
    t.integer "lock_version"
    t.text "body"
    t.integer "updated_by"
    t.integer "redirect"
    t.integer "parent_id"
    t.datetime "updated_at", precision: nil
    t.index ["page_id"], name: "index_page_versions_on_page_id"
  end

  create_table "pages", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "permalink"
    t.integer "lock_version", default: 0
    t.integer "updated_by"
    t.integer "redirect"
    t.integer "parent_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["permalink"], name: "index_pages_on_permalink"
    t.index ["title"], name: "index_pages_on_title"
  end

  create_table "periodic_task_groups", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.date "next_task_date"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "poll_choices", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "poll_vote_id", null: false
    t.integer "choice", null: false
    t.integer "value", null: false
    t.index ["poll_vote_id", "choice"], name: "index_poll_choices_on_poll_vote_id_and_choice", unique: true
  end

  create_table "poll_votes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "poll_id", null: false
    t.integer "user_id", null: false
    t.integer "ordergroup_id"
    t.text "note"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["poll_id", "user_id", "ordergroup_id"], name: "index_poll_votes_on_poll_id_and_user_id_and_ordergroup_id", unique: true
  end

  create_table "polls", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "created_by_user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "starts", precision: nil
    t.datetime "ends", precision: nil
    t.boolean "one_vote_per_ordergroup", default: false, null: false
    t.text "required_ordergroup_custom_fields"
    t.text "required_user_custom_fields"
    t.integer "voting_method", null: false
    t.text "choices", null: false
    t.integer "final_choice"
    t.integer "multi_select_count", default: 0, null: false
    t.integer "min_points"
    t.integer "max_points"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["final_choice"], name: "index_polls_on_final_choice"
  end

  create_table "printer_job_updates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "printer_job_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "state", null: false
    t.text "message"
    t.index ["printer_job_id", "created_at"], name: "index_printer_job_updates_on_printer_job_id_and_created_at"
  end

  create_table "printer_jobs", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "order_id"
    t.string "document", null: false
    t.integer "created_by_user_id", null: false
    t.integer "finished_by_user_id"
    t.datetime "finished_at", precision: nil
    t.index ["finished_at"], name: "index_printer_jobs_on_finished_at"
  end

  create_table "settings", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "stock_changes", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "stock_event_id"
    t.integer "order_id"
    t.integer "stock_article_id"
    t.integer "quantity", default: 0
    t.datetime "created_at", precision: nil
    t.index ["stock_article_id"], name: "index_stock_changes_on_stock_article_id"
    t.index ["stock_event_id"], name: "index_stock_changes_on_stock_event_id"
  end

  create_table "stock_events", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "supplier_id"
    t.date "date"
    t.datetime "created_at", precision: nil
    t.text "note"
    t.integer "invoice_id"
    t.string "type", null: false
    t.index ["supplier_id"], name: "index_stock_events_on_supplier_id"
  end

  create_table "supplier_categories", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.integer "financial_transaction_class_id"
    t.integer "bank_account_id"
  end

  create_table "suppliers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "address", default: "", null: false
    t.string "phone", default: "", null: false
    t.string "phone2"
    t.string "fax"
    t.string "email"
    t.string "url"
    t.string "contact_person"
    t.string "customer_number"
    t.string "delivery_days"
    t.string "order_howto"
    t.string "note"
    t.integer "shared_supplier_id"
    t.string "min_order_quantity"
    t.datetime "deleted_at", precision: nil
    t.string "shared_sync_method"
    t.string "iban"
    t.integer "supplier_category_id"
    t.index ["name"], name: "index_suppliers_on_name", unique: true
  end

  create_table "tasks", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.text "description"
    t.date "due_date"
    t.boolean "done", default: false
    t.integer "workgroup_id"
    t.datetime "created_on", precision: nil, null: false
    t.datetime "updated_on", precision: nil, null: false
    t.integer "required_users", default: 1
    t.integer "duration", default: 1
    t.integer "periodic_task_group_id"
    t.integer "created_by_user_id"
    t.index ["due_date"], name: "index_tasks_on_due_date"
    t.index ["name"], name: "index_tasks_on_name"
    t.index ["workgroup_id"], name: "index_tasks_on_workgroup_id"
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "nick"
    t.string "password_hash", default: "", null: false
    t.string "password_salt", default: "", null: false
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "phone"
    t.datetime "created_on", precision: nil, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_expires", precision: nil
    t.datetime "last_login", precision: nil
    t.datetime "last_activity", precision: nil
    t.datetime "deleted_at", precision: nil
    t.string "iban"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["nick"], name: "index_users_on_nick", unique: true
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
