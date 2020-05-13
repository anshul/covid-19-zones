# frozen_string_literal: true

class AddHospitalColsToV2ZoneCaches < ActiveRecord::Migration[6.0]
  def change
    change_table :v2_zone_caches, bulk: true do |t|
      t.bigint :current_hospitals, null: false, default: 0
      t.bigint :current_hospital_beds, null: false, default: 0
      t.bigint :current_icu_beds, null: false, default: 0

      t.jsonb :ts_hospitals, default: {}, null: false
      t.jsonb :ts_hospital_beds, default: {}, null: false
      t.jsonb :ts_icu_beds, default: {}, null: false
    end

    add_index :v2_zone_caches, :current_hospitals
    add_index :v2_zone_caches, :current_hospital_beds
    add_index :v2_zone_caches, :current_icu_beds
  end
end
