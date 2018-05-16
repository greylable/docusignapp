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

ActiveRecord::Schema.define(version: 2018_05_16_102555) do

  create_table "newenvelopes", force: :cascade do |t|
    t.string "envelope_id"
    t.integer "rental"
    t.string "email"
    t.string "name"
    t.string "nric"
    t.string "mailing_address"
    t.string "driver_phone_no"
    t.datetime "birthday"
    t.datetime "pickup_date"
    t.string "vehicle_make"
    t.string "vehicle_model"
    t.string "vehicle_colour"
    t.string "licence_plate"
    t.string "master_rate"
    t.float "weekly_rate"
    t.string "min_rental_period"
    t.integer "deposit"
    t.string "payee_name"
    t.string "name_of_bank"
    t.string "bank_address"
    t.string "bank_account_no"
    t.string "bank_code"
    t.string "branch_code"
    t.string "swift_code"
    t.string "driver_licence_no"
    t.datetime "expiration_date"
    t.string "driver_licence_class"
    t.string "emergency_name"
    t.string "emergency_nric"
    t.string "emergency_mailing_address"
    t.string "emergency_email"
    t.string "emergency_phone_no"
    t.datetime "emergency_birthday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_newenvelopes_on_user_id"
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "voidenvelopes", force: :cascade do |t|
    t.string "name"
    t.string "envelope_id"
    t.string "void_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "status"
    t.index ["user_id"], name: "index_voidenvelopes_on_user_id"
  end

end