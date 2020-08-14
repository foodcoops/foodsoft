# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200718074329) do

  create_table "article_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name",        default: "", null: false
    t.string "description"
    t.index ["name"], name: "index_article_categories_on_name", unique: true, using: :btree
  end

  create_table "article_prices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "article_id"
    t.decimal  "price",         precision: 8, scale: 2, default: "0.0", null: false
    t.decimal  "tax",           precision: 8, scale: 2, default: "0.0", null: false
    t.decimal  "deposit",       precision: 8, scale: 2, default: "0.0", null: false
    t.integer  "unit_quantity"
    t.datetime "created_at"
    t.index ["article_id"], name: "index_article_prices_on_article_id", using: :btree
  end

  create_table "articles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                                   default: "",    null: false
    t.integer  "supplier_id",                                            default: 0,     null: false
    t.integer  "article_category_id",                                    default: 0,     null: false
    t.string   "unit",                                                   default: "",    null: false
    t.string   "note"
    t.boolean  "availability",                                           default: true,  null: false
    t.string   "manufacturer"
    t.string   "origin"
    t.datetime "shared_updated_on"
    t.decimal  "price",                          precision: 8, scale: 2
    t.float    "tax",                 limit: 24
    t.decimal  "deposit",                        precision: 8, scale: 2, default: "0.0"
    t.integer  "unit_quantity",                                          default: 1,     null: false
    t.string   "order_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "type"
    t.integer  "quantity",                                               default: 0
    t.index ["article_category_id"], name: "index_articles_on_article_category_id", using: :btree
    t.index ["name", "supplier_id"], name: "index_articles_on_name_and_supplier_id", using: :btree
    t.index ["supplier_id"], name: "index_articles_on_supplier_id", using: :btree
    t.index ["type"], name: "index_articles_on_type", using: :btree
  end

  create_table "assignments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id",  default: 0,     null: false
    t.integer "task_id",  default: 0,     null: false
    t.boolean "accepted", default: false
    t.index ["user_id", "task_id"], name: "index_assignments_on_user_id_and_task_id", unique: true, using: :btree
  end

  create_table "bank_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                                               null: false
    t.string   "iban"
    t.string   "description"
    t.decimal  "balance",                   precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "last_import"
    t.string   "import_continuation_point"
  end

  create_table "bank_transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "bank_account_id",                                            null: false
    t.string  "external_id"
    t.date    "date"
    t.decimal "amount",                             precision: 8, scale: 2, null: false
    t.string  "iban"
    t.string  "reference"
    t.text    "text",              limit: 65535
    t.text    "receipt",           limit: 65535
    t.binary  "image",             limit: 16777215
    t.integer "financial_link_id"
    t.index ["financial_link_id"], name: "index_bank_transactions_on_financial_link_id", using: :btree
  end

  create_table "deliveries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.date     "delivered_on"
    t.datetime "created_at"
    t.text     "note",         limit: 65535
    t.integer  "invoice_id"
    t.index ["supplier_id"], name: "index_deliveries_on_supplier_id", using: :btree
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "mime"
    t.binary   "data",               limit: 16777215
    t.integer  "created_by_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.index ["parent_id"], name: "index_documents_on_parent_id", using: :btree
  end

  create_table "financial_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT" do |t|
    t.text "note", limit: 65535
  end

  create_table "financial_transaction_classes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
  end

  create_table "financial_transaction_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",                           null: false
    t.integer "financial_transaction_class_id", null: false
    t.string  "name_short"
    t.integer "bank_account_id"
    t.index ["name_short"], name: "index_financial_transaction_types_on_name_short", using: :btree
  end

  create_table "financial_transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "ordergroup_id",                                                       default: 0
    t.decimal  "amount",                                      precision: 8, scale: 2, default: "0.0", null: false
    t.text     "note",                          limit: 65535,                                         null: false
    t.integer  "user_id",                                                             default: 0,     null: false
    t.datetime "created_on",                                                                          null: false
    t.integer  "financial_link_id"
    t.integer  "financial_transaction_type_id",                                                       null: false
    t.integer  "reverts_id"
    t.integer  "group_order_id"
    t.index ["ordergroup_id"], name: "index_financial_transactions_on_ordergroup_id", using: :btree
    t.index ["reverts_id"], name: "index_financial_transactions_on_reverts_id", unique: true, using: :btree
  end

  create_table "group_order_article_quantities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "group_order_article_id", default: 0, null: false
    t.integer  "quantity",               default: 0
    t.integer  "tolerance",              default: 0
    t.datetime "created_on",                         null: false
    t.index ["group_order_article_id"], name: "index_group_order_article_quantities_on_group_order_article_id", using: :btree
  end

  create_table "group_order_articles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "group_order_id",                           default: 0, null: false
    t.integer  "order_article_id",                         default: 0, null: false
    t.integer  "quantity",                                 default: 0, null: false
    t.integer  "tolerance",                                default: 0, null: false
    t.datetime "updated_on",                                           null: false
    t.decimal  "result",           precision: 8, scale: 3
    t.decimal  "result_computed",  precision: 8, scale: 3
    t.index ["group_order_id", "order_article_id"], name: "goa_index", unique: true, using: :btree
    t.index ["group_order_id"], name: "index_group_order_articles_on_group_order_id", using: :btree
    t.index ["order_article_id"], name: "index_group_order_articles_on_order_article_id", using: :btree
  end

  create_table "group_orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "ordergroup_id"
    t.integer  "order_id",                                   default: 0,     null: false
    t.decimal  "price",              precision: 8, scale: 2, default: "0.0", null: false
    t.integer  "lock_version",                               default: 0,     null: false
    t.datetime "updated_on",                                                 null: false
    t.integer  "updated_by_user_id"
    t.decimal  "transport",          precision: 8, scale: 2
    t.index ["order_id"], name: "index_group_orders_on_order_id", using: :btree
    t.index ["ordergroup_id", "order_id"], name: "index_group_orders_on_ordergroup_id_and_order_id", unique: true, using: :btree
    t.index ["ordergroup_id"], name: "index_group_orders_on_ordergroup_id", using: :btree
  end

  create_table "groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type",                                                            default: "",    null: false
    t.string   "name",                                                            default: "",    null: false
    t.string   "description"
    t.decimal  "account_balance",                        precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_on",                                                                      null: false
    t.boolean  "role_admin",                                                      default: false, null: false
    t.boolean  "role_suppliers",                                                  default: false, null: false
    t.boolean  "role_article_meta",                                               default: false, null: false
    t.boolean  "role_finance",                                                    default: false, null: false
    t.boolean  "role_orders",                                                     default: false, null: false
    t.datetime "deleted_at"
    t.string   "contact_person"
    t.string   "contact_phone"
    t.string   "contact_address"
    t.text     "stats",                    limit: 65535
    t.integer  "next_weekly_tasks_number",                                        default: 8
    t.boolean  "ignore_apple_restriction",                                        default: false
    t.boolean  "role_invoices",                                                   default: false, null: false
    t.date     "break_start"
    t.date     "break_end"
    t.boolean  "role_pickups",                                                    default: false, null: false
    t.index ["name"], name: "index_groups_on_name", unique: true, using: :btree
  end

  create_table "invites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "token",      default: "", null: false
    t.datetime "expires_at",              null: false
    t.integer  "group_id",   default: 0,  null: false
    t.integer  "user_id",    default: 0,  null: false
    t.string   "email",      default: "", null: false
    t.index ["token"], name: "index_invites_on_token", using: :btree
  end

  create_table "invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.string   "number"
    t.date     "date"
    t.date     "paid_on"
    t.text     "note",               limit: 65535
    t.decimal  "amount",                              precision: 8, scale: 2, default: "0.0", null: false
    t.decimal  "deposit",                             precision: 8, scale: 2, default: "0.0", null: false
    t.decimal  "deposit_credit",                      precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_user_id"
    t.string   "attachment_mime"
    t.binary   "attachment_data",    limit: 16777215
    t.integer  "financial_link_id"
    t.index ["supplier_id"], name: "index_invoices_on_supplier_id", using: :btree
  end

  create_table "links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",                          null: false
    t.string  "url",                           null: false
    t.integer "workgroup_id"
    t.boolean "indirect",      default: false, null: false
    t.string  "authorization"
  end

  create_table "mail_delivery_status", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at"
    t.string   "email",                            null: false
    t.string   "message",                          null: false
    t.string   "attachment_mime"
    t.binary   "attachment_data", limit: 16777215
    t.index ["email"], name: "index_mail_delivery_status_on_email", using: :btree
  end

  create_table "memberships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "group_id", default: 0, null: false
    t.integer "user_id",  default: 0, null: false
    t.index ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true, using: :btree
  end

  create_table "message_recipients", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "message_id",              null: false
    t.integer  "user_id",                 null: false
    t.integer  "email_state", default: 0, null: false
    t.datetime "read_at"
    t.index ["message_id"], name: "index_message_recipients_on_message_id", using: :btree
    t.index ["user_id", "read_at"], name: "index_message_recipients_on_user_id_and_read_at", using: :btree
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "sender_id"
    t.string   "subject",                                         null: false
    t.text     "body",           limit: 65535
    t.boolean  "private",                         default: false
    t.datetime "created_at"
    t.integer  "reply_to"
    t.integer  "group_id"
    t.string   "salt"
    t.binary   "received_email", limit: 16777215
  end

  create_table "oauth_access_grants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "resource_owner_id",               null: false
    t.integer  "application_id",                  null: false
    t.string   "token",                           null: false
    t.integer  "expires_in",                      null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree
  end

  create_table "oauth_access_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree
  end

  create_table "oauth_applications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                      null: false
    t.string   "uid",                                       null: false
    t.string   "secret",                                    null: false
    t.text     "redirect_uri", limit: 65535,                null: false
    t.string   "scopes",                     default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confidential",               default: true, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree
  end

  create_table "order_articles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order_id",         default: 0, null: false
    t.integer "article_id",       default: 0, null: false
    t.integer "quantity",         default: 0, null: false
    t.integer "tolerance",        default: 0, null: false
    t.integer "units_to_order",   default: 0, null: false
    t.integer "lock_version",     default: 0, null: false
    t.integer "article_price_id"
    t.integer "units_billed"
    t.integer "units_received"
    t.index ["order_id", "article_id"], name: "index_order_articles_on_order_id_and_article_id", unique: true, using: :btree
    t.index ["order_id"], name: "index_order_articles_on_order_id", using: :btree
  end

  create_table "order_comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.text     "text",       limit: 65535
    t.datetime "created_at"
    t.index ["order_id"], name: "index_order_comments_on_order_id", using: :btree
  end

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "supplier_id"
    t.text     "note",               limit: 65535
    t.datetime "starts"
    t.datetime "ends"
    t.string   "state",                                                    default: "open"
    t.integer  "lock_version",                                             default: 0,      null: false
    t.integer  "updated_by_user_id"
    t.decimal  "foodcoop_result",                  precision: 8, scale: 2
    t.integer  "created_by_user_id"
    t.datetime "boxfill"
    t.date     "pickup"
    t.integer  "invoice_id"
    t.datetime "last_sent_mail"
    t.integer  "end_action",                                               default: 0,      null: false
    t.decimal  "transport",                        precision: 8, scale: 2
    t.index ["state"], name: "index_orders_on_state", using: :btree
  end

  create_table "page_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "page_id"
    t.integer  "lock_version"
    t.text     "body",         limit: 65535
    t.integer  "updated_by"
    t.integer  "redirect"
    t.integer  "parent_id"
    t.datetime "updated_at"
    t.index ["page_id"], name: "index_page_versions_on_page_id", using: :btree
  end

  create_table "pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.text     "body",         limit: 65535
    t.string   "permalink"
    t.integer  "lock_version",               default: 0
    t.integer  "updated_by"
    t.integer  "redirect"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["permalink"], name: "index_pages_on_permalink", using: :btree
    t.index ["title"], name: "index_pages_on_title", using: :btree
  end

  create_table "periodic_task_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "next_task_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "poll_choices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "poll_vote_id", null: false
    t.integer "choice",       null: false
    t.integer "value",        null: false
    t.index ["poll_vote_id", "choice"], name: "index_poll_choices_on_poll_vote_id_and_choice", unique: true, using: :btree
  end

  create_table "poll_votes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "poll_id",                     null: false
    t.integer  "user_id",                     null: false
    t.integer  "ordergroup_id"
    t.text     "note",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["poll_id", "user_id", "ordergroup_id"], name: "index_poll_votes_on_poll_id_and_user_id_and_ordergroup_id", unique: true, using: :btree
  end

  create_table "polls", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "created_by_user_id",                                              null: false
    t.string   "name",                                                            null: false
    t.text     "description",                       limit: 65535
    t.datetime "starts"
    t.datetime "ends"
    t.boolean  "one_vote_per_ordergroup",                         default: false, null: false
    t.text     "required_ordergroup_custom_fields", limit: 65535
    t.text     "required_user_custom_fields",       limit: 65535
    t.integer  "voting_method",                                                   null: false
    t.string   "choices",                                                         null: false
    t.integer  "final_choice"
    t.integer  "multi_select_count",                              default: 0,     null: false
    t.integer  "min_points"
    t.integer  "max_points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["final_choice"], name: "index_polls_on_final_choice", using: :btree
  end

  create_table "printer_job_updates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "printer_job_id",               null: false
    t.datetime "created_at",                   null: false
    t.string   "state",                        null: false
    t.text     "message",        limit: 65535
    t.index ["printer_job_id", "created_at"], name: "index_printer_job_updates_on_printer_job_id_and_created_at", using: :btree
  end

  create_table "printer_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "order_id"
    t.string   "document",            null: false
    t.integer  "created_by_user_id",  null: false
    t.integer  "finished_by_user_id"
    t.datetime "finished_at"
    t.index ["finished_at"], name: "index_printer_jobs_on_finished_at", using: :btree
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "var",                      null: false
    t.text     "value",      limit: 65535
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree
  end

  create_table "stock_changes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "delivery_id"
    t.integer  "order_id"
    t.integer  "stock_article_id"
    t.integer  "quantity",         default: 0
    t.datetime "created_at"
    t.integer  "stock_taking_id"
    t.index ["delivery_id"], name: "index_stock_changes_on_delivery_id", using: :btree
    t.index ["stock_article_id"], name: "index_stock_changes_on_stock_article_id", using: :btree
    t.index ["stock_taking_id"], name: "index_stock_changes_on_stock_taking_id", using: :btree
  end

  create_table "stock_takings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "date"
    t.text     "note",       limit: 65535
    t.datetime "created_at"
  end

  create_table "supplier_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "name",                           null: false
    t.string  "description"
    t.integer "financial_transaction_class_id", null: false
  end

  create_table "suppliers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                 default: "", null: false
    t.string   "address",              default: "", null: false
    t.string   "phone",                default: "", null: false
    t.string   "phone2"
    t.string   "fax"
    t.string   "email"
    t.string   "url"
    t.string   "contact_person"
    t.string   "customer_number"
    t.string   "delivery_days"
    t.string   "order_howto"
    t.string   "note"
    t.integer  "shared_supplier_id"
    t.string   "min_order_quantity"
    t.datetime "deleted_at"
    t.string   "shared_sync_method"
    t.string   "iban"
    t.integer  "supplier_category_id",              null: false
    t.index ["name"], name: "index_suppliers_on_name", unique: true, using: :btree
  end

  create_table "tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                 default: "",    null: false
    t.text     "description",            limit: 65535
    t.date     "due_date"
    t.boolean  "done",                                 default: false
    t.integer  "workgroup_id"
    t.datetime "created_on",                                           null: false
    t.datetime "updated_on",                                           null: false
    t.integer  "required_users",                       default: 1
    t.integer  "duration",                             default: 1
    t.integer  "periodic_task_group_id"
    t.integer  "created_by_user_id"
    t.index ["due_date"], name: "index_tasks_on_due_date", using: :btree
    t.index ["name"], name: "index_tasks_on_name", using: :btree
    t.index ["workgroup_id"], name: "index_tasks_on_workgroup_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "nick"
    t.string   "password_hash",                           default: "", null: false
    t.string   "password_salt",                           default: "", null: false
    t.string   "first_name",                              default: "", null: false
    t.string   "last_name",                               default: "", null: false
    t.string   "email",                                   default: "", null: false
    t.string   "phone"
    t.datetime "created_on",                                           null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_expires"
    t.datetime "last_login"
    t.datetime "last_activity"
    t.datetime "deleted_at"
    t.string   "iban"
    t.string   "attachment_mime"
    t.binary   "attachment_data",        limit: 16777215
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["nick"], name: "index_users_on_nick", unique: true, using: :btree
  end

end
