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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141211145650) do

  create_table "access_grants", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "code"
    t.string   "access_token"
    t.string   "refresh_token"
    t.datetime "access_token_expires_at"
    t.string   "state"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "access_grants", ["client_id"], :name => "index_access_grants_on_client_id"
  add_index "access_grants", ["code"], :name => "index_access_grants_on_code"
  add_index "access_grants", ["user_id"], :name => "index_access_grants_on_user_id"

  create_table "admin_users", :force => true do |t|
    t.string   "username",               :default => "",    :null => false
    t.string   "email"
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "role"
    t.boolean  "manage_roles",           :default => false
    t.boolean  "is_locked",              :default => false
    t.boolean  "deleted",                :default => false
    t.integer  "msp_id"
  end

  add_index "admin_users", ["deleted"], :name => "index_admin_users_on_deleted"
  add_index "admin_users", ["is_locked"], :name => "index_admin_users_on_is_locked"
  add_index "admin_users", ["manage_roles"], :name => "index_admin_users_on_manage_roles"
  add_index "admin_users", ["msp_id"], :name => "index_admin_users_on_msp_id"
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true
  add_index "admin_users", ["username"], :name => "index_admin_users_on_username"

  create_table "async_jobs", :force => true do |t|
    t.string   "job_owner"
    t.text     "csv_errors",       :limit => 4294967295
    t.string   "status"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "csv_updated_at"
    t.integer  "admin_user_id"
  end

  add_index "async_jobs", ["admin_user_id"], :name => "index_async_jobs_on_admin_user_id"

  create_table "cart_items", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "quantity",       :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_item_id"
  end

  add_index "cart_items", ["cart_id"], :name => "index_cart_items_on_cart_id"
  add_index "cart_items", ["client_item_id"], :name => "index_cart_items_on_client_item_id"

  create_table "carts", :force => true do |t|
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "user_scheme_id"
  end

  add_index "carts", ["user_scheme_id"], :name => "index_carts_on_user_scheme_id"

  create_table "catalog_items", :force => true do |t|
    t.integer "client_item_id",     :null => false
    t.integer "catalog_owner_id"
    t.string  "catalog_owner_type"
  end

  add_index "catalog_items", ["catalog_owner_id", "catalog_owner_type"], :name => "index_catalog_items_on_catalog_owner_id_and_catalog_owner_type"
  add_index "catalog_items", ["catalog_owner_id"], :name => "index_catalog_items_on_catalog_owner_id"
  add_index "catalog_items", ["catalog_owner_type"], :name => "index_catalog_items_on_catalog_owner_type"
  add_index "catalog_items", ["client_item_id"], :name => "index_catalog_items_on_client_item_id"

  create_table "categories", :force => true do |t|
    t.string   "title"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.string   "ancestry"
    t.string   "slug"
    t.decimal  "service_charge",   :precision => 20, :scale => 2, :default => 0.0
    t.decimal  "delivery_charges", :precision => 20, :scale => 2, :default => 0.0
    t.integer  "msp_id"
  end

  add_index "categories", ["ancestry"], :name => "index_categories_on_ancestry"
  add_index "categories", ["msp_id"], :name => "index_categories_on_msp_id"

  create_table "client_catalogs", :force => true do |t|
  end

  create_table "client_invoices", :force => true do |t|
    t.integer  "client_id",                             :null => false
    t.string   "invoice_type",                          :null => false
    t.text     "amount_breakup"
    t.date     "invoice_date"
    t.date     "due_date"
    t.integer  "points",         :default => 0
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "status",         :default => "pending"
    t.integer  "inv_sequence"
    t.boolean  "deleted",        :default => false
  end

  add_index "client_invoices", ["client_id"], :name => "index_client_invoices_on_client_id"
  add_index "client_invoices", ["deleted"], :name => "index_client_invoices_on_deleted"
  add_index "client_invoices", ["inv_sequence"], :name => "index_client_invoices_on_inv_sequence"
  add_index "client_invoices", ["invoice_date"], :name => "index_client_invoices_on_invoice_date"
  add_index "client_invoices", ["invoice_type"], :name => "index_client_invoices_on_invoice_type"
  add_index "client_invoices", ["status"], :name => "index_client_invoices_on_status"

  create_table "client_items", :force => true do |t|
    t.integer  "item_id",                                                             :null => false
    t.decimal  "client_price",      :precision => 20, :scale => 2
    t.decimal  "margin",            :precision => 20, :scale => 2
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",                                          :default => false
    t.integer  "client_catalog_id",                                                   :null => false
  end

  add_index "client_items", ["client_catalog_id"], :name => "index_client_items_on_client_catalog_id"
  add_index "client_items", ["client_price"], :name => "index_client_items_on_client_price"
  add_index "client_items", ["deleted"], :name => "index_client_items_on_deleted"
  add_index "client_items", ["item_id"], :name => "index_client_items_on_item_id"
  add_index "client_items", ["margin"], :name => "index_client_items_on_margin"

  create_table "client_managers", :force => true do |t|
    t.integer "client_id"
    t.integer "admin_user_id"
    t.string  "name"
    t.string  "email"
    t.string  "mobile_number"
  end

  add_index "client_managers", ["admin_user_id"], :name => "index_client_managers_on_admin_user_id"
  add_index "client_managers", ["client_id"], :name => "index_client_managers_on_client_id"

  create_table "client_payments", :force => true do |t|
    t.integer  "client_invoice_id",                                    :null => false
    t.string   "bank_name"
    t.string   "payment_mode",                                         :null => false
    t.string   "transaction_reference"
    t.date     "paid_date",                                            :null => false
    t.datetime "credited_at"
    t.decimal  "amount_paid",           :precision => 20, :scale => 2, :null => false
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "client_payments", ["client_invoice_id"], :name => "index_client_payments_on_client_invoice_id"
  add_index "client_payments", ["credited_at"], :name => "index_client_payments_on_credited_at"
  add_index "client_payments", ["paid_date"], :name => "index_client_payments_on_paid_date"

  create_table "client_point_credits", :force => true do |t|
    t.integer  "client_id"
    t.integer  "points"
    t.datetime "created_at"
  end

  add_index "client_point_credits", ["client_id"], :name => "index_client_point_credits_on_client_id"

  create_table "client_point_reports", :force => true do |t|
    t.integer  "client_id"
    t.date     "trans_date"
    t.integer  "credit",     :default => 0
    t.integer  "debit",      :default => 0
    t.integer  "balance",    :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "client_point_reports", ["client_id"], :name => "index_client_point_reports_on_client_id"
  add_index "client_point_reports", ["trans_date"], :name => "index_client_point_reports_on_trans_date"

  create_table "client_resellers", :force => true do |t|
    t.integer  "client_id",                           :null => false
    t.integer  "reseller_id",                         :null => false
    t.integer  "finders_fee"
    t.date     "payout_start_date"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "assigned",          :default => true
    t.date     "payout_end_date"
  end

  add_index "client_resellers", ["client_id", "reseller_id"], :name => "index_client_resellers_on_client_id_and_reseller_id"
  add_index "client_resellers", ["client_id"], :name => "index_client_resellers_on_client_id"
  add_index "client_resellers", ["reseller_id"], :name => "index_client_resellers_on_reseller_id"

  create_table "clients", :force => true do |t|
    t.string   "client_name",                                                 :default => "",    :null => false
    t.float    "points_to_rupee_ratio"
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone_number"
    t.string   "description"
    t.string   "notes"
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
    t.integer  "client_catalog_id"
    t.string   "domain_name"
    t.string   "code"
    t.string   "custom_theme_file_name"
    t.string   "custom_theme_content_type"
    t.integer  "custom_theme_file_size"
    t.datetime "custom_theme_updated_at"
    t.string   "client_key"
    t.string   "client_secret"
    t.string   "client_url"
    t.boolean  "allow_sso"
    t.boolean  "allow_otp"
    t.boolean  "allow_otp_email"
    t.boolean  "allow_otp_mobile"
    t.integer  "otp_code_expiration"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "sms_based",                                                   :default => false
    t.boolean  "is_locked",                                                   :default => false
    t.decimal  "ots_charges",                  :precision => 20, :scale => 2
    t.boolean  "is_fixed_amount",                                             :default => false
    t.decimal  "fixed_amount",                 :precision => 20, :scale => 2
    t.boolean  "is_participant_rate",                                         :default => false
    t.decimal  "participant_rate",             :precision => 20, :scale => 2
    t.decimal  "puc_rate",                     :precision => 20, :scale => 2
    t.text     "address"
    t.date     "expiry_date"
    t.integer  "opening_balance",                                             :default => 0
    t.boolean  "is_live"
    t.string   "sms_number",                                                  :default => ""
    t.boolean  "allow_total_points_deduction",                                :default => false
    t.integer  "msp_id"
    t.string   "cu_email"
    t.string   "cu_cc_email"
    t.string   "cu_phone_number"
  end

  add_index "clients", ["allow_otp"], :name => "index_clients_on_allow_otp"
  add_index "clients", ["allow_otp_email"], :name => "index_clients_on_allow_otp_email"
  add_index "clients", ["allow_otp_mobile"], :name => "index_clients_on_allow_otp_mobile"
  add_index "clients", ["allow_sso"], :name => "index_clients_on_allow_sso"
  add_index "clients", ["client_catalog_id"], :name => "index_clients_on_client_catalog_id"
  add_index "clients", ["client_key", "client_secret"], :name => "index_clients_on_client_key_and_client_secret", :unique => true
  add_index "clients", ["client_name"], :name => "index_clients_on_client_name", :unique => true
  add_index "clients", ["expiry_date"], :name => "index_clients_on_expiry_date"
  add_index "clients", ["is_live"], :name => "index_clients_on_is_live"
  add_index "clients", ["is_locked"], :name => "index_clients_on_is_locked"
  add_index "clients", ["msp_id"], :name => "index_clients_on_msp_id"
  add_index "clients", ["sms_based"], :name => "index_clients_on_sms_based"

  create_table "clients_resellers", :id => false, :force => true do |t|
    t.integer "client_id"
    t.integer "reseller_id"
  end

  add_index "clients_resellers", ["client_id", "reseller_id"], :name => "index_clients_resellers_on_client_id_and_reseller_id", :unique => true

  create_table "clubs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "rank"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",                       :default => 0
    t.integer  "attempts",                       :default => 0
    t.text     "handler",    :limit => 16777215
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "altered_delayed_jobs_priority"

  create_table "download_reports", :force => true do |t|
    t.string   "filename"
    t.text     "url"
    t.text     "report_errors"
    t.string   "status"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "admin_user_id"
  end

  add_index "download_reports", ["admin_user_id"], :name => "index_download_reports_on_admin_user_id"

  create_table "draft_items", :force => true do |t|
    t.string   "title",                                                               :null => false
    t.string   "listing_id",                                                          :null => false
    t.string   "model_no",                                                            :null => false
    t.decimal  "mrp",                                  :precision => 20, :scale => 2, :null => false
    t.decimal  "channel_price",                        :precision => 20, :scale => 2, :null => false
    t.text     "description",         :limit => 255
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.integer  "category_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "supplier_id"
    t.text     "specification",       :limit => 30000
    t.string   "brand"
    t.string   "geographic_reach"
    t.string   "delivery_time"
    t.integer  "available_quantity"
    t.datetime "available_till_date"
    t.decimal  "supplier_margin",                      :precision => 20, :scale => 2
    t.integer  "item_id"
    t.integer  "msp_id"
  end

  add_index "draft_items", ["category_id"], :name => "index_draft_items_on_category_id"
  add_index "draft_items", ["msp_id"], :name => "index_draft_items_on_msp_id"
  add_index "draft_items", ["supplier_id"], :name => "index_draft_items_on_supplier_id"

  create_table "item_suppliers", :force => true do |t|
    t.integer  "item_id",                                                               :null => false
    t.integer  "supplier_id",                                                           :null => false
    t.string   "geographic_reach"
    t.string   "delivery_time"
    t.integer  "available_quantity"
    t.datetime "available_till_date"
    t.decimal  "channel_price",       :precision => 20, :scale => 2
    t.string   "listing_id"
    t.decimal  "supplier_margin",     :precision => 20, :scale => 2
    t.decimal  "mrp",                 :precision => 20, :scale => 2
    t.string   "model_no"
    t.boolean  "is_preferred",                                       :default => false
  end

  add_index "item_suppliers", ["item_id", "supplier_id"], :name => "index_item_suppliers_on_item_id_and_supplier_id", :unique => true

  create_table "items", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",                                                                               :null => false
    t.datetime "updated_at",                                                                               :null => false
    t.string   "slug"
    t.integer  "category_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "model_no"
    t.text     "specification",      :limit => 30000
    t.string   "brand"
    t.decimal  "bvc_price",                           :precision => 20, :scale => 2
    t.decimal  "margin",                              :precision => 20, :scale => 2
    t.string   "status",                                                             :default => "active"
    t.integer  "msp_id"
  end

  add_index "items", ["category_id"], :name => "index_items_on_category_id"
  add_index "items", ["msp_id"], :name => "index_items_on_msp_id"
  add_index "items", ["status"], :name => "index_items_on_status"
  add_index "items", ["title"], :name => "index_items_on_title"

  create_table "language_templates", :force => true do |t|
    t.string   "name",                             :null => false
    t.text     "template"
    t.string   "status",     :default => "active"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "level_clubs", :force => true do |t|
    t.integer "scheme_id"
    t.integer "level_id",  :null => false
    t.integer "club_id",   :null => false
  end

  add_index "level_clubs", ["club_id", "scheme_id"], :name => "index_level_clubs_on_club_id_and_scheme_id"
  add_index "level_clubs", ["id"], :name => "index_level_clubs_on_id", :unique => true
  add_index "level_clubs", ["level_id", "club_id"], :name => "index_level_clubs_on_level_id_and_club_id", :unique => true
  add_index "level_clubs", ["level_id", "scheme_id"], :name => "index_level_clubs_on_level_id_and_scheme_id"
  add_index "level_clubs", ["scheme_id"], :name => "index_level_clubs_on_scheme_id"

  create_table "levels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "msps", :force => true do |t|
    t.string   "name"
    t.string   "contact_name"
    t.string   "phone_number"
    t.string   "email"
    t.text     "address"
    t.decimal  "opening_balance", :precision => 20, :scale => 2
    t.decimal  "setup_charge",    :precision => 20, :scale => 2
    t.decimal  "fixed_amount",    :precision => 20, :scale => 2
    t.text     "plan_details"
    t.text     "notes"
    t.string   "status",                                         :default => "active"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id",                                                                :null => false
    t.integer  "quantity",                                             :default => 1,     :null => false
    t.integer  "points",                                               :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                                               :default => "new"
    t.datetime "delivered_at"
    t.integer  "client_item_id"
    t.integer  "scheme_id",                                                               :null => false
    t.string   "shipping_agent"
    t.string   "shipping_code"
    t.datetime "sent_to_supplier_date"
    t.datetime "sent_for_delivery"
    t.integer  "points_claimed"
    t.decimal  "price_in_rupees",       :precision => 20, :scale => 2
    t.decimal  "bvc_margin",            :precision => 20, :scale => 2
    t.decimal  "bvc_price",             :precision => 20, :scale => 2
    t.decimal  "channel_price",         :precision => 20, :scale => 2
    t.decimal  "mrp",                   :precision => 20, :scale => 2
    t.integer  "supplier_id"
  end

  add_index "order_items", ["client_item_id"], :name => "index_order_items_on_client_item_id"
  add_index "order_items", ["order_id"], :name => "index_order_items_on_order_id"
  add_index "order_items", ["scheme_id"], :name => "index_order_items_on_scheme_id"
  add_index "order_items", ["supplier_id"], :name => "index_order_items_on_supplier_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id",                :null => false
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "address_name",           :null => false
    t.text     "address_body",           :null => false
    t.string   "address_city",           :null => false
    t.string   "address_state",          :null => false
    t.string   "address_zip_code",       :null => false
    t.string   "address_phone",          :null => false
    t.string   "address_landmark"
    t.string   "address_landline_phone"
    t.integer  "points"
  end

  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "pack_tier_configs", :force => true do |t|
    t.integer  "reward_item_point_id", :null => false
    t.integer  "user_role_id",         :null => false
    t.integer  "codes",                :null => false
    t.string   "tier_name"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "pack_tier_configs", ["reward_item_point_id"], :name => "index_pack_tier_configs_on_reward_item_point_id"
  add_index "pack_tier_configs", ["user_role_id"], :name => "index_pack_tier_configs_on_user_role_id"

  create_table "product_code_links", :force => true do |t|
    t.integer  "unique_item_code_id"
    t.string   "linkable_type",       :limit => 16
    t.integer  "linkable_id"
    t.datetime "created_at",                        :null => false
  end

  add_index "product_code_links", ["linkable_type", "linkable_id"], :name => "index_product_code_links_on_linkable_type_and_linkable_id"
  add_index "product_code_links", ["unique_item_code_id"], :name => "index_product_code_links_on_unique_item_code_id"

  create_table "regional_managers", :force => true do |t|
    t.integer  "client_id"
    t.integer  "admin_user_id"
    t.string   "region",        :limit => 32
    t.string   "name",          :limit => 32
    t.string   "mobile_number", :limit => 32
    t.string   "email",         :limit => 46
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "type"
    t.text     "address"
    t.string   "pincode"
  end

  add_index "regional_managers", ["admin_user_id"], :name => "index_regional_managers_on_admin_user_id"
  add_index "regional_managers", ["client_id"], :name => "index_regional_managers_on_client_id"
  add_index "regional_managers", ["type"], :name => "index_regional_managers_on_type"

  create_table "regional_managers_telecom_circles", :force => true do |t|
    t.integer "regional_manager_id"
    t.integer "telecom_circle_id"
  end

  add_index "regional_managers_telecom_circles", ["regional_manager_id"], :name => "index_regional_managers_telecom_circles_on_regional_manager_id"
  add_index "regional_managers_telecom_circles", ["telecom_circle_id"], :name => "index_regional_managers_telecom_circles_on_telecom_circle_id"

  create_table "regional_managers_users", :id => false, :force => true do |t|
    t.integer "regional_manager_id"
    t.integer "user_id"
  end

  add_index "regional_managers_users", ["regional_manager_id"], :name => "index_regional_managers_users_on_regional_manager_id"
  add_index "regional_managers_users", ["user_id"], :name => "index_regional_managers_users_on_user_id"

  create_table "resellers", :force => true do |t|
    t.string   "name"
    t.string   "phone_number"
    t.string   "email"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "admin_user_id"
  end

  add_index "resellers", ["admin_user_id"], :name => "index_resellers_on_admin_user_id"

  create_table "reward_item_points", :force => true do |t|
    t.integer  "reward_item_id"
    t.integer  "points"
    t.string   "pack_size"
    t.string   "metric"
    t.string   "status",         :default => "active"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "reward_item_points", ["reward_item_id"], :name => "index_reward_item_points_on_reward_item_id"
  add_index "reward_item_points", ["status"], :name => "index_reward_item_points_on_status"

  create_table "reward_items", :force => true do |t|
    t.integer  "client_id"
    t.integer  "scheme_id"
    t.string   "name"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "reward_items", ["client_id"], :name => "index_reward_items_on_client_id"
  add_index "reward_items", ["scheme_id"], :name => "index_reward_items_on_scheme_id"
  add_index "reward_items", ["status"], :name => "index_reward_items_on_status"

  create_table "scheme_transactions", :force => true do |t|
    t.integer  "client_id"
    t.integer  "user_id"
    t.integer  "scheme_id"
    t.string   "action"
    t.string   "transaction_type"
    t.integer  "transaction_id"
    t.integer  "points",           :default => 0, :null => false
    t.integer  "remaining_points", :default => 0, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "scheme_transactions", ["action"], :name => "index_scheme_transactions_on_action"
  add_index "scheme_transactions", ["client_id"], :name => "index_scheme_transactions_on_client_id"
  add_index "scheme_transactions", ["scheme_id"], :name => "index_scheme_transactions_on_scheme_id"
  add_index "scheme_transactions", ["transaction_id"], :name => "index_scheme_transactions_on_transaction_id"
  add_index "scheme_transactions", ["transaction_type"], :name => "index_scheme_transactions_on_transaction_type"
  add_index "scheme_transactions", ["user_id"], :name => "index_scheme_transactions_on_user_id"

  create_table "schemes", :force => true do |t|
    t.integer  "client_id",                                  :null => false
    t.string   "name",                                       :null => false
    t.string   "poster_file_name"
    t.string   "poster_content_type"
    t.integer  "poster_file_size"
    t.datetime "poster_updated_at"
    t.date     "redemption_start_date"
    t.date     "redemption_end_date"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "hero_image_file_name"
    t.string   "hero_image_content_type"
    t.integer  "hero_image_file_size"
    t.datetime "hero_image_updated_at"
    t.integer  "total_budget_in_rupees"
    t.string   "slug"
    t.boolean  "single_redemption",       :default => false
  end

  add_index "schemes", ["client_id"], :name => "index_schemes_on_client_id"
  add_index "schemes", ["id"], :name => "index_schemes_on_id", :unique => true
  add_index "schemes", ["slug"], :name => "index_schemes_on_slug"

  create_table "slabs", :force => true do |t|
    t.float   "lower_limit"
    t.float   "payout_percentage"
    t.integer "client_reseller_id"
  end

  add_index "slabs", ["client_reseller_id"], :name => "index_slabs_on_client_reseller_id"

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.string   "phone_number"
    t.text     "address"
    t.text     "description"
    t.string   "supplied_categories"
    t.string   "geographic_reach"
    t.text     "additional_notes"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "delivery_time"
    t.string   "payment_terms"
    t.integer  "msp_id"
  end

  add_index "suppliers", ["msp_id"], :name => "index_suppliers_on_msp_id"

  create_table "targets", :force => true do |t|
    t.integer  "start"
    t.integer  "user_scheme_id"
    t.integer  "club_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "targets", ["club_id"], :name => "index_targets_on_club_id"
  add_index "targets", ["user_scheme_id"], :name => "index_targets_on_user_scheme_id"

  create_table "telecom_circles", :force => true do |t|
    t.string   "code",        :limit => 6
    t.text     "description", :limit => 3000
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "telecom_circles", ["code"], :name => "index_telecom_circles_on_code"

  create_table "unique_item_codes", :force => true do |t|
    t.string   "code"
    t.date     "expiry_date"
    t.integer  "user_id"
    t.datetime "used_at"
    t.datetime "created_at"
    t.integer  "reward_item_point_id"
    t.integer  "pack_tier_config_id"
    t.string   "ancestry"
    t.integer  "pack_number"
  end

  add_index "unique_item_codes", ["ancestry"], :name => "index_unique_item_codes_on_ancestry"
  add_index "unique_item_codes", ["code"], :name => "index_unique_item_codes_on_code", :unique => true
  add_index "unique_item_codes", ["expiry_date"], :name => "index_unique_item_codes_on_expiry_date"
  add_index "unique_item_codes", ["pack_tier_config_id"], :name => "index_unique_item_codes_on_pack_tier_config_id"
  add_index "unique_item_codes", ["reward_item_point_id"], :name => "index_unique_item_codes_on_reward_item_point_id"
  add_index "unique_item_codes", ["used_at"], :name => "index_unique_item_codes_on_used_at"
  add_index "unique_item_codes", ["user_id"], :name => "index_unique_item_codes_on_user_id"

  create_table "user_roles", :force => true do |t|
    t.integer  "client_id",  :null => false
    t.string   "name",       :null => false
    t.string   "ancestry"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "color_hex"
  end

  add_index "user_roles", ["ancestry"], :name => "index_user_roles_on_ancestry"
  add_index "user_roles", ["client_id"], :name => "index_user_roles_on_client_id"
  add_index "user_roles", ["name"], :name => "index_user_roles_on_name"

  create_table "user_schemes", :force => true do |t|
    t.integer  "scheme_id",                           :null => false
    t.integer  "user_id",                             :null => false
    t.integer  "total_points",         :default => 0, :null => false
    t.integer  "redeemed_points",      :default => 0, :null => false
    t.integer  "current_achievements"
    t.string   "region"
    t.integer  "level_id"
    t.integer  "club_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_schemes", ["club_id"], :name => "index_user_schemes_on_club_id"
  add_index "user_schemes", ["level_id"], :name => "index_user_schemes_on_level_id"
  add_index "user_schemes", ["scheme_id"], :name => "index_user_schemes_on_scheme_id"
  add_index "user_schemes", ["user_id"], :name => "index_user_schemes_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => ""
    t.string   "encrypted_password",     :default => "",        :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "username",               :default => "",        :null => false
    t.string   "participant_id",         :default => "",        :null => false
    t.string   "full_name",              :default => "",        :null => false
    t.string   "mobile_number",          :default => "",        :null => false
    t.string   "landline_number",        :default => "",        :null => false
    t.string   "address"
    t.string   "pincode"
    t.string   "notes"
    t.integer  "client_id"
    t.string   "activation_status"
    t.datetime "activated_at"
    t.string   "otp_secret_key"
    t.string   "status",                 :default => "pending"
    t.text     "extra_options"
    t.string   "ancestry"
    t.integer  "user_role_id"
    t.integer  "telecom_circle_id"
  end

  add_index "users", ["ancestry"], :name => "index_users_on_ancestry"
  add_index "users", ["client_id"], :name => "index_users_on_client_id"
  add_index "users", ["otp_secret_key"], :name => "index_users_on_otp_secret_key"
  add_index "users", ["participant_id"], :name => "index_users_on_participant_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["status"], :name => "index_users_on_status"
  add_index "users", ["telecom_circle_id"], :name => "index_users_on_telecom_circle_id"
  add_index "users", ["user_role_id"], :name => "index_users_on_user_role_id"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
