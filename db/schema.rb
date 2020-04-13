# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_13_151911) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "patients", force: :cascade do |t|
    t.string "slug", null: false
    t.string "code", null: false
    t.string "external_code", null: false
    t.string "status", null: false
    t.string "source", null: false
    t.string "zone_code", null: false
    t.string "name"
    t.string "gender"
    t.string "age"
    t.string "nationality"
    t.string "transmission_type"
    t.date "announced_on", null: false
    t.date "status_changed_on"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_patients_on_code", unique: true
    t.index ["external_code", "source"], name: "index_patients_on_external_code_and_source", unique: true
    t.index ["slug"], name: "index_patients_on_slug", unique: true
    t.index ["status"], name: "index_patients_on_status"
    t.index ["zone_code"], name: "index_patients_on_zone_code"
  end

  create_table "sources", force: :cascade do |t|
    t.string "slug", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.jsonb "details", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_sources_on_code", unique: true
    t.index ["slug"], name: "index_sources_on_slug", unique: true
  end

  create_table "taggings", force: :cascade do |t|
    t.string "taggable_tag"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "slug", null: false
    t.string "code", null: false
    t.string "name"
    t.string "tag_md"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_tags_on_code", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
    t.index ["tag_md"], name: "index_tags_on_tag_md"
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
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "zones", force: :cascade do |t|
    t.string "slug", null: false
    t.string "code", null: false
    t.string "type", null: false
    t.string "name"
    t.string "parent_zone"
    t.string "zone_md"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_zones_on_code", unique: true
    t.index ["slug"], name: "index_zones_on_slug", unique: true
    t.index ["zone_md"], name: "index_zones_on_zone_md"
  end

end
