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

ActiveRecord::Schema.define(version: 20150301000000) do

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
    t.boolean  "availability",        limit: 1,                           default: true, null: false
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
    t.boolean "accepted", limit: 1, default: false
  end

  add_index "assignments", ["user_id", "task_id"], name: "index_assignments_on_user_id_and_task_id", unique: true, using: :btree

  create_table "deliveries", force: :cascade do |t|
    t.integer  "supplier_id",  limit: 4
    t.date     "delivered_on"
    t.datetime "created_at"
    t.text     "note",         limit: 65535
  end

  add_index "deliveries", ["supplier_id"], name: "index_deliveries_on_supplier_id", using: :btree

  create_table "financial_transactions", force: :cascade do |t|
    t.integer  "ordergroup_id", limit: 4,                             default: 0, null: false
    t.decimal  "amount",                      precision: 8, scale: 2, default: 0, null: false
    t.text     "note",          limit: 65535,                                     null: false
    t.integer  "user_id",       limit: 4,                             default: 0, null: false
    t.datetime "created_on",                                                      null: false
  end

  add_index "financial_transactions", ["ordergroup_id"], name: "index_financial_transactions_on_ordergroup_id", using: :btree

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
    t.integer  "ordergroup_id",      limit: 4,                         default: 0, null: false
    t.integer  "order_id",           limit: 4,                         default: 0, null: false
    t.decimal  "price",                        precision: 8, scale: 2, default: 0, null: false
    t.integer  "lock_version",       limit: 4,                         default: 0, null: false
    t.datetime "updated_on",                                                       null: false
    t.integer  "updated_by_user_id", limit: 4
  end

  add_index "group_orders", ["order_id"], name: "index_group_orders_on_order_id", using: :btree
  add_index "group_orders", ["ordergroup_id", "order_id"], name: "index_group_orders_on_ordergroup_id_and_order_id", unique: true, using: :btree
  add_index "group_orders", ["ordergroup_id"], name: "index_group_orders_on_ordergroup_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "type",                     limit: 255,                            default: "",    null: false
    t.string   "name",                     limit: 255,                            default: "",    null: false
    t.string   "description",              limit: 255
    t.decimal  "account_balance",                        precision: 12, scale: 2, default: 0,     null: false
    t.datetime "created_on",                                                                      null: false
    t.boolean  "role_admin",               limit: 1,                              default: false, null: false
    t.boolean  "role_suppliers",           limit: 1,                              default: false, null: false
    t.boolean  "role_article_meta",        limit: 1,                              default: false, null: false
    t.boolean  "role_finance",             limit: 1,                              default: false, null: false
    t.boolean  "role_orders",              limit: 1,                              default: false, null: false
    t.datetime "deleted_at"
    t.string   "contact_person",           limit: 255
    t.string   "contact_phone",            limit: 255
    t.string   "contact_address",          limit: 255
    t.text     "stats",                    limit: 65535
    t.integer  "next_weekly_tasks_number", limit: 4,                              default: 8
    t.boolean  "ignore_apple_restriction", limit: 1,                              default: false
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true, using: :btree

  create_table "invites", force: :cascade do |t|
    t.string   "token",      limit: 255, default: "", null: false
    t.datetime "expires_at",                          null: false
    t.integer  "group_id",   limit: 4,   default: 0,  null: false
    t.integer  "user_id",    limit: 4,   default: 0,  null: false
    t.string   "email",      limit: 255, default: "", null: false
  end

  add_index "invites", ["token"], name: "index_invites_on_token", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "supplier_id",    limit: 4
    t.integer  "delivery_id",    limit: 4
    t.integer  "order_id",       limit: 4
    t.string   "number",         limit: 255
    t.date     "date"
    t.date     "paid_on"
    t.text     "note",           limit: 65535
    t.decimal  "amount",                       precision: 8, scale: 2, default: 0, null: false
    t.decimal  "deposit",                      precision: 8, scale: 2, default: 0, null: false
    t.decimal  "deposit_credit",               precision: 8, scale: 2, default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoices", ["delivery_id"], name: "index_invoices_on_delivery_id", using: :btree
  add_index "invoices", ["supplier_id"], name: "index_invoices_on_supplier_id", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer "group_id", limit: 4, default: 0, null: false
    t.integer "user_id",  limit: 4, default: 0, null: false
  end

  add_index "memberships", ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "sender_id",      limit: 4
    t.text     "recipients_ids", limit: 65535
    t.string   "subject",        limit: 255,                   null: false
    t.text     "body",           limit: 65535
    t.integer  "email_state",    limit: 4,     default: 0,     null: false
    t.boolean  "private",        limit: 1,     default: false
    t.datetime "created_at"
    t.integer  "reply_to",       limit: 4
    t.integer  "group_id",       limit: 4
  end

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

  add_index "order_articles", ["order_id", "article_id"], name: "index_order_articles_on_order_id_and_article_id", unique: true, using: :btree
  add_index "order_articles", ["order_id"], name: "index_order_articles_on_order_id", using: :btree

  create_table "order_comments", force: :cascade do |t|
    t.integer  "order_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "text",       limit: 65535
    t.datetime "created_at"
  end

  add_index "order_comments", ["order_id"], name: "index_order_comments_on_order_id", using: :btree

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
  end

  add_index "orders", ["state"], name: "index_orders_on_state", using: :btree

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

  add_index "pages", ["permalink"], name: "index_pages_on_permalink", using: :btree
  add_index "pages", ["title"], name: "index_pages_on_title", using: :btree

  create_table "periodic_task_groups", force: :cascade do |t|
    t.date     "next_task_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

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
  add_index "stock_changes", ["stock_article_id"], name: "index_stock_changes_on_stock_article_id", using: :btree
  add_index "stock_changes", ["stock_taking_id"], name: "index_stock_changes_on_stock_taking_id", using: :btree

  create_table "stock_takings", force: :cascade do |t|
    t.date     "date"
    t.text     "note",       limit: 65535
    t.datetime "created_at"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string   "name",               limit: 255, default: "", null: false
    t.string   "address",            limit: 255, default: "", null: false
    t.string   "phone",              limit: 255, default: "", null: false
    t.string   "phone2",             limit: 255
    t.string   "fax",                limit: 255
    t.string   "email",              limit: 255
    t.string   "url",                limit: 255
    t.string   "contact_person",     limit: 255
    t.string   "customer_number",    limit: 255
    t.string   "delivery_days",      limit: 255
    t.string   "order_howto",        limit: 255
    t.string   "note",               limit: 255
    t.integer  "shared_supplier_id", limit: 4
    t.string   "min_order_quantity", limit: 255
    t.datetime "deleted_at"
    t.string   "shared_sync_method", limit: 255
  end

  add_index "suppliers", ["name"], name: "index_suppliers_on_name", unique: true, using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "name",                   limit: 255, default: "",    null: false
    t.string   "description",            limit: 255
    t.date     "due_date"
    t.boolean  "done",                   limit: 1,   default: false
    t.integer  "workgroup_id",           limit: 4
    t.datetime "created_on",                                         null: false
    t.datetime "updated_on",                                         null: false
    t.integer  "required_users",         limit: 4,   default: 1
    t.integer  "duration",               limit: 4,   default: 1
    t.integer  "periodic_task_group_id", limit: 4
  end

  add_index "tasks", ["due_date"], name: "index_tasks_on_due_date", using: :btree
  add_index "tasks", ["name"], name: "index_tasks_on_name", using: :btree
  add_index "tasks", ["workgroup_id"], name: "index_tasks_on_workgroup_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "nick",                   limit: 255
    t.string   "password_hash",          limit: 255, default: "", null: false
    t.string   "password_salt",          limit: 255, default: "", null: false
    t.string   "first_name",             limit: 255, default: "", null: false
    t.string   "last_name",              limit: 255, default: "", null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "phone",                  limit: 255
    t.datetime "created_on",                                      null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_expires"
    t.datetime "last_login"
    t.datetime "last_activity"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["nick"], name: "index_users_on_nick", unique: true, using: :btree

end
