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

ActiveRecord::Schema.define(version: 2020_04_13_092853) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "patients", force: :cascade do |t|
    t.string "patient_number", null: false
    t.string "status", null: false
    t.string "name"
    t.string "tagged_district"
    t.string "tagged_city"
    t.string "tagged_state"
    t.string "tagged_country"
    t.string "gender"
    t.string "age"
    t.string "nationality"
    t.jsonb "sources"
    t.date "date_announced", null: false
    t.date "date_status_changed"
    t.date "type_of_transmission"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["patient_number"], name: "index_patients_on_patient_number", unique: true
    t.index ["status"], name: "index_patients_on_status"
    t.index ["tagged_city"], name: "index_patients_on_tagged_city"
    t.index ["tagged_country"], name: "index_patients_on_tagged_country"
    t.index ["tagged_district"], name: "index_patients_on_tagged_district"
    t.index ["tagged_state"], name: "index_patients_on_tagged_state"
  end

  create_table "tagged_patients", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tagged_zones", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name"
    t.string "tag_md"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.string "name"
    t.string "zone_md"
    t.string "tag_slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_zones_on_slug", unique: true
    t.index ["tag_slug"], name: "index_zones_on_tag_slug"
    t.index ["zone_md"], name: "index_zones_on_zone_md"
  end

end
