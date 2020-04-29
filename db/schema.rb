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

ActiveRecord::Schema.define(version: 2020_04_29_090551) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "data_snapshots", force: :cascade do |t|
    t.string "source", null: false
    t.string "api_code", null: false
    t.string "signature", null: false
    t.string "job_code", null: false
    t.jsonb "raw_data", default: {}
    t.datetime "downloaded_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["downloaded_at"], name: "index_data_snapshots_on_downloaded_at"
    t.index ["job_code"], name: "index_data_snapshots_on_job_code"
    t.index ["source", "api_code", "signature"], name: "data_snapshots_uniq", unique: true
  end

  create_table "jobs", force: :cascade do |t|
    t.string "code", null: false
    t.string "slug", null: false
    t.string "source", null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "crashed_at"
    t.bigint "update_count", default: 0, null: false
    t.jsonb "logs", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_jobs_on_code", unique: true
    t.index ["slug"], name: "index_jobs_on_slug", unique: true
    t.index ["source"], name: "index_jobs_on_source"
  end

  create_table "patients", force: :cascade do |t|
    t.string "slug", null: false
    t.string "code", null: false
    t.string "source", null: false
    t.string "external_code", null: false
    t.string "zone_code", null: false
    t.string "external_signature", null: false
    t.jsonb "external_details", default: {}, null: false
    t.date "announced_on", null: false
    t.string "status", null: false
    t.date "status_changed_on"
    t.string "name"
    t.string "gender"
    t.string "age"
    t.datetime "first_imported_at"
    t.datetime "last_imported_at"
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
    t.string "name"
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

  create_table "time_series_points", force: :cascade do |t|
    t.date "dated"
    t.string "target_code"
    t.string "target_type"
    t.decimal "population", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "area_sq_km", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "density", precision: 14, scale: 4, default: "0.0", null: false
    t.decimal "announced", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "recovered", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "deceased", precision: 14, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dated", "target_code", "target_type"], name: "time_series_points_uniq", unique: true
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
    t.string "name"
    t.string "role", default: "contributor", null: false
    t.string "github_handle"
    t.string "twitter_handle"
    t.text "bio_md"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "v2_facts", force: :cascade do |t|
    t.string "entity_slug", null: false
    t.string "entity_type", null: false
    t.string "fact_type", null: false
    t.string "signature", null: false
    t.integer "sequence", null: false
    t.jsonb "details", default: {}, null: false
    t.datetime "happened_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entity_slug", "sequence"], name: "index_v2_facts_on_entity_slug_and_sequence", unique: true
    t.index ["fact_type"], name: "index_v2_facts_on_fact_type"
    t.index ["happened_at"], name: "index_v2_facts_on_happened_at"
  end

  create_table "v2_origins", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "data_category", null: false
    t.string "attribution_text", null: false
    t.string "source_name", null: false
    t.string "source_subname", null: false
    t.string "source_url"
    t.string "md", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "details", default: {}, null: false
    t.index ["code"], name: "index_v2_origins_on_code", unique: true
    t.index ["data_category"], name: "index_v2_origins_on_data_category"
    t.index ["name"], name: "index_v2_origins_on_name"
  end

  create_table "v2_posts", force: :cascade do |t|
    t.string "code", null: false
    t.string "unit_code", null: false
    t.string "zone_code", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_v2_posts_on_code", unique: true
    t.index ["unit_code", "zone_code"], name: "index_v2_posts_on_unit_code_and_zone_code", unique: true
  end

  create_table "v2_snapshots", force: :cascade do |t|
    t.string "origin_code", null: false
    t.string "signature", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "downloaded_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["downloaded_at"], name: "index_v2_snapshots_on_downloaded_at"
    t.index ["origin_code", "signature"], name: "v2_snapshots_signature_unique", unique: true
  end

  create_table "v2_streams", force: :cascade do |t|
    t.string "code", null: false
    t.string "category", null: false
    t.string "unit_code", null: false
    t.string "origin_code", null: false
    t.jsonb "time_series", default: {}, null: false
    t.date "dated", null: false
    t.integer "priority", default: 50, null: false
    t.string "md", default: "", null: false
    t.bigint "snapshot_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "min_count", precision: 14, scale: 2, null: false
    t.decimal "max_count", precision: 14, scale: 2, null: false
    t.decimal "cumulative_count", precision: 14, scale: 2, null: false
    t.datetime "min_date", null: false
    t.datetime "max_date", null: false
    t.datetime "downloaded_at"
    t.text "attribution_md"
    t.index ["attribution_md"], name: "index_v2_streams_on_attribution_md"
    t.index ["category", "unit_code", "origin_code"], name: "v2_stream_signature_unique", unique: true
    t.index ["code"], name: "v2_stream_unique", unique: true
    t.index ["cumulative_count"], name: "index_v2_streams_on_cumulative_count"
    t.index ["dated"], name: "index_v2_streams_on_dated"
    t.index ["downloaded_at"], name: "index_v2_streams_on_downloaded_at"
    t.index ["max_count"], name: "index_v2_streams_on_max_count"
    t.index ["max_date"], name: "index_v2_streams_on_max_date"
    t.index ["min_count"], name: "index_v2_streams_on_min_count"
    t.index ["min_date"], name: "index_v2_streams_on_min_date"
    t.index ["priority"], name: "index_v2_streams_on_priority"
    t.index ["snapshot_id"], name: "index_v2_streams_on_snapshot_id"
  end

  create_table "v2_units", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "category", null: false
    t.string "parent_code"
    t.string "topojson_file"
    t.string "topojson_key"
    t.string "topojson_value"
    t.jsonb "topojson_override"
    t.bigint "population", null: false
    t.integer "population_year", null: false
    t.decimal "area_sq_km", null: false
    t.jsonb "details"
    t.string "maintainer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category"], name: "index_v2_units_on_category"
    t.index ["code"], name: "index_v2_units_on_code", unique: true
    t.index ["parent_code"], name: "index_v2_units_on_parent_code"
  end

  create_table "v2_zone_caches", force: :cascade do |t|
    t.string "code", null: false
    t.bigint "current_actives", null: false
    t.bigint "cumulative_infections", null: false
    t.bigint "cumulative_recoveries", null: false
    t.bigint "cumulative_fatalities", null: false
    t.bigint "cumulative_tests", null: false
    t.datetime "as_of", null: false
    t.date "start", null: false
    t.date "stop", null: false
    t.jsonb "attributions_md", default: {}, null: false
    t.jsonb "unit_codes", default: [], null: false, array: true
    t.jsonb "ts_actives", default: {}, null: false
    t.jsonb "ts_infections", default: {}, null: false
    t.jsonb "ts_recoveries", default: {}, null: false
    t.jsonb "ts_fatalities", default: {}, null: false
    t.jsonb "ts_tests", default: {}, null: false
    t.datetime "cached_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "streams", default: {}, null: false
    t.bigint "population", null: false
    t.decimal "area_sq_km", null: false
    t.index ["as_of"], name: "index_v2_zone_caches_on_as_of"
    t.index ["code"], name: "index_v2_zone_caches_on_code", unique: true
    t.index ["cumulative_fatalities"], name: "index_v2_zone_caches_on_cumulative_fatalities"
    t.index ["cumulative_infections"], name: "index_v2_zone_caches_on_cumulative_infections"
    t.index ["cumulative_recoveries"], name: "index_v2_zone_caches_on_cumulative_recoveries"
    t.index ["cumulative_tests"], name: "index_v2_zone_caches_on_cumulative_tests"
    t.index ["current_actives"], name: "index_v2_zone_caches_on_current_actives"
    t.index ["start"], name: "index_v2_zone_caches_on_start"
    t.index ["stop"], name: "index_v2_zone_caches_on_stop"
  end

  create_table "v2_zones", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "category", null: false
    t.string "parent_code"
    t.text "md", default: "", null: false
    t.string "maintainer"
    t.datetime "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "aliases", default: [], null: false, array: true
    t.string "search_key", default: "", null: false
    t.index ["category"], name: "index_v2_zones_on_category"
    t.index ["code"], name: "index_v2_zones_on_code", unique: true
    t.index ["parent_code"], name: "index_v2_zones_on_parent_code"
    t.index ["published_at"], name: "index_v2_zones_on_published_at"
    t.index ["search_key"], name: "index_v2_zones_on_search_key"
  end

  create_table "zones", force: :cascade do |t|
    t.string "type", null: false
    t.string "slug", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.string "search_name", null: false
    t.string "parent_zone"
    t.string "zone_md", default: "", null: false
    t.decimal "pop", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "area", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "density", precision: 14, scale: 4, default: "0.0", null: false
    t.jsonb "details", default: "{}", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_zones_on_code", unique: true
    t.index ["name"], name: "index_zones_on_name"
    t.index ["slug"], name: "index_zones_on_slug", unique: true
    t.index ["type"], name: "index_zones_on_type"
  end

  add_foreign_key "v2_posts", "v2_units", column: "unit_code", primary_key: "code"
  add_foreign_key "v2_posts", "v2_zones", column: "zone_code", primary_key: "code"
  add_foreign_key "v2_streams", "v2_origins", column: "origin_code", primary_key: "code"
  add_foreign_key "v2_streams", "v2_snapshots", column: "snapshot_id"
  add_foreign_key "v2_streams", "v2_units", column: "unit_code", primary_key: "code"
end
