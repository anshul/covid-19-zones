# frozen_string_literal: true

class CreateV2ZoneCaches < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_zone_caches do |t|
      t.string :code, null: false
      t.bigint :current_actives, null: false
      t.bigint :cumulative_infections, null: false
      t.bigint :cumulative_recoveries, null: false
      t.bigint :cumulative_fatalities, null: false
      t.bigint :cumulative_tests, null: false
      t.datetime :as_of, null: false
      t.date :start, null: false
      t.date :stop, null: false
      t.jsonb :attributions_md, default: {}, null: false
      t.jsonb :unit_codes, default: [], array: true, null: false
      t.jsonb :ts_actives, default: {}, null: false
      t.jsonb :ts_infections, default: {}, null: false
      t.jsonb :ts_recoveries, default: {}, null: false
      t.jsonb :ts_fatalities, default: {}, null: false
      t.jsonb :ts_tests, default: {}, null: false
      t.datetime :cached_at, null: false

      t.timestamps
    end
    add_index :v2_zone_caches, :code, unique: true
    add_index :v2_zone_caches, :as_of
    add_index :v2_zone_caches, :start
    add_index :v2_zone_caches, :stop
    add_index :v2_zone_caches, :current_actives
    add_index :v2_zone_caches, :cumulative_infections
    add_index :v2_zone_caches, :cumulative_recoveries
    add_index :v2_zone_caches, :cumulative_fatalities
    add_index :v2_zone_caches, :cumulative_tests
  end
end
