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

ActiveRecord::Schema.define(version: 2018_06_25_065449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "ip_newenvelopes", force: :cascade do |t|
    t.string "ip_email"
    t.string "nric"
    t.string "ip_name"
    t.string "driver_phone_no"
    t.string "licence_plate"
    t.string "min_rental_period"
    t.string "name_of_bank"
    t.string "bank_account_no"
    t.string "emergency_name"
    t.string "emergency_phone_no"
    t.string "vehicle_make"
    t.string "vehicle_model"
    t.string "pickup_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_ip_newenvelopes_on_user_id"
  end

  create_table "live_statuses", force: :cascade do |t|
    t.string "envelope_id"
    t.string "rental"
    t.string "email"
    t.string "name"
    t.string "nric"
    t.string "mailing_address"
    t.string "driver_phone_no"
    t.string "birthday"
    t.string "pickup_date"
    t.string "vehicle_make"
    t.string "vehicle_model"
    t.string "vehicle_colour"
    t.string "licence_plate"
    t.string "master_rate"
    t.string "weekly_rate"
    t.string "min_rental_period"
    t.string "deposit"
    t.string "accesscode"
    t.string "note"
    t.string "status"
    t.string "email_blurb"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "masterlists", force: :cascade do |t|
    t.string "envelope_id"
    t.string "created_time"
    t.string "recipient_email"
    t.string "status"
    t.string "recipient_type"
    t.string "completed_time"
    t.string "declined_time"
    t.string "declined_reason"
    t.string "subject_title"
    t.string "auth_status"
    t.string "auth_timestamp"
    t.string "delivered_date_time"
    t.string "note"
    t.string "accesscode"
    t.string "recipient_status"
    t.string "rental"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_masterlists_on_user_id"
  end

  create_table "newenvelopes", force: :cascade do |t|
    t.string "rental"
    t.string "email"
    t.string "name"
    t.string "nric"
    t.string "mailing_address"
    t.string "driver_phone_no"
    t.string "birthday"
    t.string "pickup_date"
    t.string "vehicle_make"
    t.string "vehicle_model"
    t.string "vehicle_colour"
    t.string "licence_plate"
    t.string "master_rate"
    t.float "weekly_rate"
    t.string "min_rental_period"
    t.string "deposit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "accesscode"
    t.string "note"
    t.index ["user_id"], name: "index_newenvelopes_on_user_id"
  end

  create_table "resendenvs", force: :cascade do |t|
    t.string "envelope_id"
    t.string "rental"
    t.string "email"
    t.string "name"
    t.string "nric"
    t.string "mailing_address"
    t.string "driver_phone_no"
    t.string "birthday"
    t.string "pickup_date"
    t.string "vehicle_make"
    t.string "vehicle_model"
    t.string "vehicle_colour"
    t.string "licence_plate"
    t.string "master_rate"
    t.float "weekly_rate"
    t.string "min_rental_period"
    t.string "deposit"
    t.string "accesscode"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "email_blurb"
    t.string "status"
    t.index ["user_id"], name: "index_resendenvs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin_user"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "voidenvelopes", force: :cascade do |t|
    t.string "name"
    t.string "envelope_id"
    t.string "void_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "status"
    t.index ["user_id"], name: "index_voidenvelopes_on_user_id"
  end

  add_foreign_key "ip_newenvelopes", "users"
  add_foreign_key "masterlists", "users"
  add_foreign_key "newenvelopes", "users"
  add_foreign_key "resendenvs", "users"
  add_foreign_key "voidenvelopes", "users"
end
