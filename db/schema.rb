# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20200718074332) do

  create_table "article_categories", force: :cascade do |t|
    t.string "name",        limit: 255, default: "", null: false
    t.string "description", limit: 255
  end

  add_index "article_categories", ["name"], name: "index_article_categories_on_name", unique: true, using: :btree

  create_table "article_prices", force: :cascade do |t|
    t.integer  "article_id",    limit: 4
    t.decimal  "price",                   precision: 8, scale: 2, default: 0, null: false
    t.decimal  "tax",                     precision: 8, scale: 2, default: 0, null: false
    t.decimal  "deposit",                 precision: 8, scale: 2, default: 0, null: false
    t.integer  "unit_quantity", limit: 4
    t.datetime "created_at"
  end

  add_index "article_prices", ["article_id"], name: "index_article_prices_on_article_id", using: :btree

  create_table "articles", force: :cascade do |t|
    t.string   "name",                limit: 255,                         default: "",   null: false
    t.integer  "supplier_id",         limit: 4,                           default: 0,    null: false
    t.integer  "article_category_id", limit: 4,                           default: 0,    null: false
    t.string   "unit",                limit: 255,                         default: "",   null: false
    t.string   "note",                limit: 255
    t.boolean  "availability",                                            default: true, null: false
    t.string   "manufacturer",        limit: 255
    t.string   "origin",              limit: 255
    t.datetime "shared_updated_on"
    t.decimal  "price",                           precision: 8, scale: 2
    t.float    "tax",                 limit: 24
    t.decimal  "deposit",                         precision: 8, scale: 2, default: 0
    t.integer  "unit_quantity",       limit: 4,                           default: 1,    null: false
    t.string   "order_number",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "type",                limit: 255
    t.integer  "quantity",            limit: 4,                           default: 0
  end

  add_index "articles", ["article_category_id"], name: "index_articles_on_article_category_id", using: :btree
  add_index "articles", ["name", "supplier_id"], name: "index_articles_on_name_and_supplier_id", using: :btree
  add_index "articles", ["supplier_id"], name: "index_articles_on_supplier_id", using: :btree
  add_index "articles", ["type"], name: "index_articles_on_type", using: :btree

  create_table "assignments", force: :cascade do |t|
    t.integer "user_id",  limit: 4, default: 0,     null: false
    t.integer "task_id",  limit: 4, default: 0,     null: false
    t.boolean "accepted",           default: false
  end

  add_index "assignments", ["task_id"], name: "fk_rails_b7c53ee3b6", using: :btree
  add_index "assignments", ["user_id", "task_id"], name: "index_assignments_on_user_id_and_task_id", unique: true, using: :btree

  create_table "bank_accounts", force: :cascade do |t|
    t.string   "name",                      limit: 255,                                      null: false
    t.string   "iban",                      limit: 255
    t.string   "description",               limit: 255
    t.decimal  "balance",                               precision: 12, scale: 2, default: 0, null: false
    t.datetime "last_import"
    t.string   "import_continuation_point", limit: 255
  end

  create_table "bank_transactions", force: :cascade do |t|
    t.integer "bank_account_id",   limit: 4,                                null: false
    t.string  "external_id",       limit: 255
    t.date    "date"
    t.decimal "amount",                             precision: 8, scale: 2, null: false
    t.string  "iban",              limit: 255
    t.string  "reference",         limit: 255
    t.text    "text",              limit: 65535
    t.text    "receipt",           limit: 65535
    t.binary  "image",             limit: 16777215
    t.integer "financial_link_id", limit: 4
  end

  add_index "bank_transactions", ["bank_account_id"], name: "fk_rails_e0117c6727", using: :btree
  add_index "bank_transactions", ["financial_link_id"], name: "index_bank_transactions_on_financial_link_id", using: :btree

  create_table "deliveries", force: :cascade do |t|
    t.integer  "supplier_id",  limit: 4
    t.date     "delivered_on"
    t.datetime "created_at"
    t.text     "note",         limit: 65535
    t.integer  "invoice_id",   limit: 4
  end

  add_index "deliveries", ["invoice_id"], name: "fk_rails_c9bbe97b0f", using: :btree
  add_index "deliveries", ["supplier_id"], name: "index_deliveries_on_supplier_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "mime",               limit: 255
    t.binary   "data",               limit: 16777215
    t.integer  "created_by_user_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",          limit: 4
  end

  add_index "documents", ["created_by_user_id"], name: "fk_rails_7294a1aa59", using: :btree
  add_index "documents", ["parent_id"], name: "index_documents_on_parent_id", using: :btree

  create_table "financial_links", force: :cascade do |t|
    t.text "note", limit: 65535
  end

  create_table "financial_transaction_classes", force: :cascade do |t|
    t.string "name", limit: 255, null: false
  end

  create_table "financial_transaction_types", force: :cascade do |t|
    t.string  "name",                           limit: 255, null: false
    t.integer "financial_transaction_class_id", limit: 4,   null: false
    t.string  "name_short",                     limit: 255
  end

  add_index "financial_transaction_types", ["financial_transaction_class_id"], name: "fk_rails_f2b646cddc", using: :btree
  add_index "financial_transaction_types", ["name_short"], name: "index_financial_transaction_types_on_name_short", using: :btree

  create_table "financial_transactions", force: :cascade do |t|
    t.integer  "ordergroup_id",                 limit: 4,                             default: 0, null: false
    t.decimal  "amount",                                      precision: 8, scale: 2, default: 0, null: false
    t.text     "note",                          limit: 65535,                                     null: false
    t.integer  "user_id",                       limit: 4,                             default: 0, null: false
    t.datetime "created_on",                                                                      null: false
    t.integer  "financial_link_id",             limit: 4
    t.integer  "financial_transaction_type_id", limit: 4,                                         null: false
    t.integer  "reverts_id",                    limit: 4
    t.integer  "group_order_id",                limit: 4
  end

  add_index "financial_transactions", ["financial_link_id"], name: "fk_rails_d41d3fdfae", using: :btree
  add_index "financial_transactions", ["financial_transaction_type_id"], name: "fk_rails_dba6d95fbf", using: :btree
  add_index "financial_transactions", ["group_order_id"], name: "fk_rails_88ae0ba39c", using: :btree
  add_index "financial_transactions", ["ordergroup_id"], name: "index_financial_transactions_on_ordergroup_id", using: :btree
  add_index "financial_transactions", ["reverts_id"], name: "index_financial_transactions_on_reverts_id", unique: true, using: :btree
  add_index "financial_transactions", ["user_id"], name: "fk_rails_0cbb08eeee", using: :btree

  create_table "group_order_article_quantities", force: :cascade do |t|
    t.integer  "group_order_article_id", limit: 4, default: 0, null: false
    t.integer  "quantity",               limit: 4, default: 0
    t.integer  "tolerance",              limit: 4, default: 0
    t.datetime "created_on",                                   null: false
  end

  add_index "group_order_article_quantities", ["group_order_article_id"], name: "index_group_order_article_quantities_on_group_order_article_id", using: :btree

  create_table "group_order_articles", force: :cascade do |t|
    t.integer  "group_order_id",   limit: 4,                         default: 0, null: false
    t.integer  "order_article_id", limit: 4,                         default: 0, null: false
    t.integer  "quantity",         limit: 4,                         default: 0, null: false
    t.integer  "tolerance",        limit: 4,                         default: 0, null: false
    t.datetime "updated_on",                                                     null: false
    t.decimal  "result",                     precision: 8, scale: 3
    t.decimal  "result_computed",            precision: 8, scale: 3
  end

  add_index "group_order_articles", ["group_order_id", "order_article_id"], name: "goa_index", unique: true, using: :btree
  add_index "group_order_articles", ["group_order_id"], name: "index_group_order_articles_on_group_order_id", using: :btree
  add_index "group_order_articles", ["order_article_id"], name: "index_group_order_articles_on_order_article_id", using: :btree

  create_table "group_orders", force: :cascade do |t|
    t.integer  "ordergroup_id",      limit: 4
    t.integer  "order_id",           limit: 4,                         default: 0, null: false
    t.decimal  "price",                        precision: 8, scale: 2, default: 0, null: false
    t.integer  "lock_version",       limit: 4,                         default: 0, null: false
    t.datetime "updated_on",                                                       null: false
    t.integer  "updated_by_user_id", limit: 4
    t.decimal  "transport",                    precision: 8, scale: 2
  end

  add_index "group_orders", ["order_id"], name: "index_group_orders_on_order_id", using: :btree
  add_index "group_orders", ["ordergroup_id", "order_id"], name: "index_group_orders_on_ordergroup_id_and_order_id", unique: true, using: :btree
  add_index "group_orders", ["ordergroup_id"], name: "index_group_orders_on_ordergroup_id", using: :btree
  add_index "group_orders", ["updated_by_user_id"], name: "fk_rails_1889c54304", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "type",                     limit: 255,                            default: "",    null: false
    t.string   "name",                     limit: 255,                            default: "",    null: false
    t.string   "description",              limit: 255
    t.decimal  "account_balance",                        precision: 12, scale: 2, default: 0,     null: false
    t.datetime "created_on",                                                                      null: false
    t.boolean  "role_admin",                                                      default: false, null: false
    t.boolean  "role_suppliers",                                                  default: false, null: false
    t.boolean  "role_article_meta",                                               default: false, null: false
    t.boolean  "role_finance",                                                    default: false, null: false
    t.boolean  "role_orders",                                                     default: false, null: false
    t.datetime "deleted_at"
    t.string   "contact_person",           limit: 255
    t.string   "contact_phone",            limit: 255
    t.string   "contact_address",          limit: 255
    t.text     "stats",                    limit: 65535
    t.integer  "next_weekly_tasks_number", limit: 4,                              default: 8
    t.boolean  "ignore_apple_restriction",                                        default: false
    t.boolean  "role_invoices",                                                   default: false, null: false
    t.date     "break_start"
    t.date     "break_end"
    t.boolean  "role_pickups",                                                    default: false, null: false
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true, using: :btree

  create_table "invites", force: :cascade do |t|
    t.string   "token",      limit: 255, default: "", null: false
    t.datetime "expires_at",                          null: false
    t.integer  "group_id",   limit: 4,   default: 0,  null: false
    t.integer  "user_id",    limit: 4,   default: 0,  null: false
    t.string   "email",      limit: 255, default: "", null: false
  end

  add_index "invites", ["group_id"], name: "fk_rails_9e216f1ff4", using: :btree
  add_index "invites", ["token"], name: "index_invites_on_token", using: :btree
  add_index "invites", ["user_id"], name: "fk_rails_ff69dbb2ac", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "supplier_id",        limit: 4
    t.string   "number",             limit: 255
    t.date     "date"
    t.date     "paid_on"
    t.text     "note",               limit: 65535
    t.decimal  "amount",                              precision: 8, scale: 2, default: 0, null: false
    t.decimal  "deposit",                             precision: 8, scale: 2, default: 0, null: false
    t.decimal  "deposit_credit",                      precision: 8, scale: 2, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_user_id", limit: 4
    t.string   "attachment_mime",    limit: 255
    t.binary   "attachment_data",    limit: 16777215
    t.integer  "financial_link_id",  limit: 4
  end

  add_index "invoices", ["created_by_user_id"], name: "fk_rails_8fd25eeb3c", using: :btree
  add_index "invoices", ["financial_link_id"], name: "fk_rails_75b0aafe67", using: :btree
  add_index "invoices", ["supplier_id"], name: "index_invoices_on_supplier_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.string  "name",          limit: 255,                 null: false
    t.string  "url",           limit: 255,                 null: false
    t.integer "workgroup_id",  limit: 4
    t.boolean "indirect",                  default: false, null: false
    t.string  "authorization", limit: 255
  end

  create_table "mail_delivery_status", force: :cascade do |t|
    t.datetime "created_at"
    t.string   "email",           limit: 255,      null: false
    t.string   "message",         limit: 255,      null: false
    t.string   "attachment_mime", limit: 255
    t.binary   "attachment_data", limit: 16777215
  end

  add_index "mail_delivery_status", ["email"], name: "index_mail_delivery_status_on_email", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer "group_id", limit: 4, default: 0, null: false
    t.integer "user_id",  limit: 4, default: 0, null: false
  end

  add_index "memberships", ["group_id"], name: "fk_rails_aaf389f138", using: :btree
  add_index "memberships", ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true, using: :btree

  create_table "message_recipients", force: :cascade do |t|
    t.integer  "message_id",  limit: 4,             null: false
    t.integer  "user_id",     limit: 4,             null: false
    t.integer  "email_state", limit: 4, default: 0, null: false
    t.datetime "read_at"
  end

  add_index "message_recipients", ["message_id"], name: "index_message_recipients_on_message_id", using: :btree
  add_index "message_recipients", ["user_id", "read_at"], name: "index_message_recipients_on_user_id_and_read_at", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id",      limit: 4
    t.string   "subject",        limit: 255,                      null: false
    t.text     "body",           limit: 65535
    t.boolean  "private",                         default: false
    t.datetime "created_at"
    t.integer  "reply_to",       limit: 4
    t.integer  "group_id",       limit: 4
    t.string   "salt",           limit: 255
    t.binary   "received_email", limit: 16777215
  end

  add_index "messages", ["group_id"], name: "fk_rails_841b0ae6ac", using: :btree
  add_index "messages", ["sender_id"], name: "fk_rails_b8f26a382d", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 255,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4
    t.integer  "application_id",    limit: 4
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in",        limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                  null: false
    t.string   "uid",          limit: 255,                  null: false
    t.string   "secret",       limit: 255,                  null: false
    t.text     "redirect_uri", limit: 65535,                null: false
    t.string   "scopes",       limit: 255,   default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "confidential",               default: true, null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "order_articles", force: :cascade do |t|
    t.integer "order_id",         limit: 4, default: 0, null: false
    t.integer "article_id",       limit: 4, default: 0, null: false
    t.integer "quantity",         limit: 4, default: 0, null: false
    t.integer "tolerance",        limit: 4, default: 0, null: false
    t.integer "units_to_order",   limit: 4, default: 0, null: false
    t.integer "lock_version",     limit: 4, default: 0, null: false
    t.integer "article_price_id", limit: 4
    t.integer "units_billed",     limit: 4
    t.integer "units_received",   limit: 4
  end

  add_index "order_articles", ["article_id"], name: "fk_rails_44e6c21781", using: :btree
  add_index "order_articles", ["article_price_id"], name: "fk_rails_798fa38c22", using: :btree
  add_index "order_articles", ["order_id", "article_id"], name: "index_order_articles_on_order_id_and_article_id", unique: true, using: :btree
  add_index "order_articles", ["order_id"], name: "index_order_articles_on_order_id", using: :btree

  create_table "order_comments", force: :cascade do |t|
    t.integer  "order_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "text",       limit: 65535
    t.datetime "created_at"
  end

  add_index "order_comments", ["order_id"], name: "index_order_comments_on_order_id", using: :btree
  add_index "order_comments", ["user_id"], name: "fk_rails_9db67cf94d", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "supplier_id",        limit: 4
    t.text     "note",               limit: 65535
    t.datetime "starts"
    t.datetime "ends"
    t.string   "state",              limit: 255,                           default: "open"
    t.integer  "lock_version",       limit: 4,                             default: 0,      null: false
    t.integer  "updated_by_user_id", limit: 4
    t.decimal  "foodcoop_result",                  precision: 8, scale: 2
    t.integer  "created_by_user_id", limit: 4
    t.datetime "boxfill"
    t.date     "pickup"
    t.integer  "invoice_id",         limit: 4
    t.datetime "last_sent_mail"
    t.integer  "end_action",         limit: 4,                             default: 0,      null: false
    t.decimal  "transport",                        precision: 8, scale: 2
  end

  add_index "orders", ["created_by_user_id"], name: "fk_rails_30144627f8", using: :btree
  add_index "orders", ["invoice_id"], name: "fk_rails_b33ed6c672", using: :btree
  add_index "orders", ["state"], name: "index_orders_on_state", using: :btree
  add_index "orders", ["supplier_id"], name: "fk_rails_d426350910", using: :btree
  add_index "orders", ["updated_by_user_id"], name: "fk_rails_f3fe5911c4", using: :btree

  create_table "page_versions", force: :cascade do |t|
    t.integer  "page_id",      limit: 4
    t.integer  "lock_version", limit: 4
    t.text     "body",         limit: 65535
    t.integer  "updated_by",   limit: 4
    t.integer  "redirect",     limit: 4
    t.integer  "parent_id",    limit: 4
    t.datetime "updated_at"
  end

  add_index "page_versions", ["page_id"], name: "index_page_versions_on_page_id", using: :btree
  add_index "page_versions", ["parent_id"], name: "fk_rails_966d369f50", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.text     "body",         limit: 65535
    t.string   "permalink",    limit: 255
    t.integer  "lock_version", limit: 4,     default: 0
    t.integer  "updated_by",   limit: 4
    t.integer  "redirect",     limit: 4
    t.integer  "parent_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["parent_id"], name: "fk_rails_409bbac70a", using: :btree
  add_index "pages", ["permalink"], name: "index_pages_on_permalink", using: :btree
  add_index "pages", ["title"], name: "index_pages_on_title", using: :btree

  create_table "periodic_task_groups", force: :cascade do |t|
    t.date     "next_task_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "poll_choices", force: :cascade do |t|
    t.integer "poll_vote_id", limit: 4, null: false
    t.integer "choice",       limit: 4, null: false
    t.integer "value",        limit: 4, null: false
  end

  add_index "poll_choices", ["poll_vote_id", "choice"], name: "index_poll_choices_on_poll_vote_id_and_choice", unique: true, using: :btree

  create_table "poll_votes", force: :cascade do |t|
    t.integer  "poll_id",       limit: 4,     null: false
    t.integer  "user_id",       limit: 4,     null: false
    t.integer  "ordergroup_id", limit: 4
    t.text     "note",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "poll_votes", ["ordergroup_id"], name: "fk_rails_931f43cfec", using: :btree
  add_index "poll_votes", ["poll_id", "user_id", "ordergroup_id"], name: "index_poll_votes_on_poll_id_and_user_id_and_ordergroup_id", unique: true, using: :btree
  add_index "poll_votes", ["user_id"], name: "fk_rails_b64de9b025", using: :btree

  create_table "polls", force: :cascade do |t|
    t.integer  "created_by_user_id",                limit: 4,                     null: false
    t.string   "name",                              limit: 255,                   null: false
    t.text     "description",                       limit: 65535
    t.datetime "starts"
    t.datetime "ends"
    t.boolean  "one_vote_per_ordergroup",                         default: false, null: false
    t.text     "required_ordergroup_custom_fields", limit: 65535
    t.text     "required_user_custom_fields",       limit: 65535
    t.integer  "voting_method",                     limit: 4,                     null: false
    t.string   "choices",                           limit: 255,                   null: false
    t.integer  "final_choice",                      limit: 4
    t.integer  "multi_select_count",                limit: 4,     default: 0,     null: false
    t.integer  "min_points",                        limit: 4
    t.integer  "max_points",                        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "polls", ["created_by_user_id"], name: "fk_rails_ddedb38d1d", using: :btree
  add_index "polls", ["final_choice"], name: "index_polls_on_final_choice", using: :btree

  create_table "printer_job_updates", force: :cascade do |t|
    t.integer  "printer_job_id", limit: 4,     null: false
    t.datetime "created_at",                   null: false
    t.string   "state",          limit: 255,   null: false
    t.text     "message",        limit: 65535
  end

  add_index "printer_job_updates", ["printer_job_id", "created_at"], name: "index_printer_job_updates_on_printer_job_id_and_created_at", using: :btree

  create_table "printer_jobs", force: :cascade do |t|
    t.integer  "order_id",            limit: 4
    t.string   "document",            limit: 255, null: false
    t.integer  "created_by_user_id",  limit: 4,   null: false
    t.integer  "finished_by_user_id", limit: 4
    t.datetime "finished_at"
  end

  add_index "printer_jobs", ["created_by_user_id"], name: "fk_rails_a222b5a8b4", using: :btree
  add_index "printer_jobs", ["finished_at"], name: "index_printer_jobs_on_finished_at", using: :btree
  add_index "printer_jobs", ["finished_by_user_id"], name: "fk_rails_c259d78e0a", using: :btree
  add_index "printer_jobs", ["order_id"], name: "fk_rails_f691a1be68", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",        limit: 255,   null: false
    t.text     "value",      limit: 65535
    t.integer  "thing_id",   limit: 4
    t.string   "thing_type", limit: 30
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "stock_changes", force: :cascade do |t|
    t.integer  "delivery_id",      limit: 4
    t.integer  "order_id",         limit: 4
    t.integer  "stock_article_id", limit: 4
    t.integer  "quantity",         limit: 4, default: 0
    t.datetime "created_at"
    t.integer  "stock_taking_id",  limit: 4
  end

  add_index "stock_changes", ["delivery_id"], name: "index_stock_changes_on_delivery_id", using: :btree
  add_index "stock_changes", ["order_id"], name: "fk_rails_6ddf028707", using: :btree
  add_index "stock_changes", ["stock_article_id"], name: "index_stock_changes_on_stock_article_id", using: :btree
  add_index "stock_changes", ["stock_taking_id"], name: "index_stock_changes_on_stock_taking_id", using: :btree

  create_table "stock_takings", force: :cascade do |t|
    t.date     "date"
    t.text     "note",       limit: 65535
    t.datetime "created_at"
  end

  create_table "supplier_categories", force: :cascade do |t|
    t.string  "name",                           limit: 255, null: false
    t.string  "description",                    limit: 255
    t.integer "financial_transaction_class_id", limit: 4,   null: false
  end

  add_index "supplier_categories", ["financial_transaction_class_id"], name: "fk_rails_e4db9d9002", using: :btree

  create_table "suppliers", force: :cascade do |t|
    t.string   "name",                 limit: 255, default: "", null: false
    t.string   "address",              limit: 255, default: "", null: false
    t.string   "phone",                limit: 255, default: "", null: false
    t.string   "phone2",               limit: 255
    t.string   "fax",                  limit: 255
    t.string   "email",                limit: 255
    t.string   "url",                  limit: 255
    t.string   "contact_person",       limit: 255
    t.string   "customer_number",      limit: 255
    t.string   "delivery_days",        limit: 255
    t.string   "order_howto",          limit: 255
    t.string   "note",                 limit: 255
    t.integer  "shared_supplier_id",   limit: 4
    t.string   "min_order_quantity",   limit: 255
    t.datetime "deleted_at"
    t.string   "shared_sync_method",   limit: 255
    t.string   "iban",                 limit: 255
    t.integer  "supplier_category_id", limit: 4,                null: false
  end

  add_index "suppliers", ["name"], name: "index_suppliers_on_name", unique: true, using: :btree
  add_index "suppliers", ["shared_supplier_id"], name: "fk_rails_6958f49bbb", using: :btree
  add_index "suppliers", ["supplier_category_id"], name: "fk_rails_f8fa27fa1f", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "name",                   limit: 255,   default: "",    null: false
    t.text     "description",            limit: 65535
    t.date     "due_date"
    t.boolean  "done",                                 default: false
    t.integer  "workgroup_id",           limit: 4
    t.datetime "created_on",                                           null: false
    t.datetime "updated_on",                                           null: false
    t.integer  "required_users",         limit: 4,     default: 1
    t.integer  "duration",               limit: 4,     default: 1
    t.integer  "periodic_task_group_id", limit: 4
    t.integer  "created_by_user_id",     limit: 4
  end

  add_index "tasks", ["created_by_user_id"], name: "fk_rails_1f562c7b99", using: :btree
  add_index "tasks", ["due_date"], name: "index_tasks_on_due_date", using: :btree
  add_index "tasks", ["name"], name: "index_tasks_on_name", using: :btree
  add_index "tasks", ["periodic_task_group_id"], name: "fk_rails_78a5d11f82", using: :btree
  add_index "tasks", ["workgroup_id"], name: "index_tasks_on_workgroup_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "nick",                   limit: 255
    t.string   "password_hash",          limit: 255,      default: "", null: false
    t.string   "password_salt",          limit: 255,      default: "", null: false
    t.string   "first_name",             limit: 255,      default: "", null: false
    t.string   "last_name",              limit: 255,      default: "", null: false
    t.string   "email",                  limit: 255,      default: "", null: false
    t.string   "phone",                  limit: 255
    t.datetime "created_on",                                           null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_expires"
    t.datetime "last_login"
    t.datetime "last_activity"
    t.datetime "deleted_at"
    t.string   "iban",                   limit: 255
    t.string   "attachment_mime",        limit: 255
    t.binary   "attachment_data",        limit: 16777215
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["nick"], name: "index_users_on_nick", unique: true, using: :btree

  add_foreign_key "article_prices", "articles"
  add_foreign_key "articles", "article_categories"
  add_foreign_key "articles", "suppliers"
  add_foreign_key "assignments", "tasks"
  add_foreign_key "assignments", "users"
  add_foreign_key "bank_transactions", "bank_accounts"
  add_foreign_key "bank_transactions", "financial_links"
  add_foreign_key "deliveries", "invoices"
  add_foreign_key "deliveries", "suppliers"
  add_foreign_key "documents", "users", column: "created_by_user_id"
  add_foreign_key "financial_transaction_types", "financial_transaction_classes"
  add_foreign_key "financial_transactions", "financial_links"
  add_foreign_key "financial_transactions", "financial_transaction_types"
  add_foreign_key "financial_transactions", "financial_transactions", column: "reverts_id"
  add_foreign_key "financial_transactions", "group_orders"
  add_foreign_key "financial_transactions", "groups", column: "ordergroup_id"
  add_foreign_key "financial_transactions", "users"
  add_foreign_key "group_order_article_quantities", "articles", column: "group_order_article_id"
  add_foreign_key "group_order_articles", "articles", column: "order_article_id"
  add_foreign_key "group_order_articles", "group_orders"
  add_foreign_key "group_orders", "groups", column: "ordergroup_id"
  add_foreign_key "group_orders", "orders"
  add_foreign_key "group_orders", "users", column: "updated_by_user_id"
  add_foreign_key "invites", "groups"
  add_foreign_key "invites", "users"
  add_foreign_key "invoices", "financial_links"
  add_foreign_key "invoices", "suppliers"
  add_foreign_key "invoices", "users", column: "created_by_user_id"
  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "users"
  add_foreign_key "message_recipients", "messages"
  add_foreign_key "message_recipients", "users"
  add_foreign_key "messages", "groups"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "order_articles", "article_prices"
  add_foreign_key "order_articles", "articles"
  add_foreign_key "order_articles", "orders"
  add_foreign_key "order_comments", "orders"
  add_foreign_key "order_comments", "users"
  add_foreign_key "orders", "invoices"
  add_foreign_key "orders", "suppliers"
  add_foreign_key "orders", "users", column: "created_by_user_id"
  add_foreign_key "orders", "users", column: "updated_by_user_id"
  add_foreign_key "page_versions", "pages"
  add_foreign_key "page_versions", "pages", column: "parent_id"
  add_foreign_key "pages", "pages", column: "parent_id"
  add_foreign_key "poll_choices", "poll_votes"
  add_foreign_key "poll_votes", "groups", column: "ordergroup_id"
  add_foreign_key "poll_votes", "polls"
  add_foreign_key "poll_votes", "users"
  add_foreign_key "polls", "users", column: "created_by_user_id"
  add_foreign_key "printer_job_updates", "printer_jobs"
  add_foreign_key "printer_jobs", "orders"
  add_foreign_key "printer_jobs", "users", column: "created_by_user_id"
  add_foreign_key "printer_jobs", "users", column: "finished_by_user_id"
  add_foreign_key "stock_changes", "articles", column: "stock_article_id"
  add_foreign_key "stock_changes", "deliveries"
  add_foreign_key "stock_changes", "orders"
  add_foreign_key "stock_changes", "stock_takings"
  add_foreign_key "supplier_categories", "financial_transaction_classes"
  add_foreign_key "suppliers", "supplier_categories"
  add_foreign_key "suppliers", "suppliers", column: "shared_supplier_id"
  add_foreign_key "tasks", "groups", column: "periodic_task_group_id"
  add_foreign_key "tasks", "groups", column: "workgroup_id"
  add_foreign_key "tasks", "users", column: "created_by_user_id"
end
