# frozen_string_literal: true

class AddUnitDetailsToV2ZoneCaches < ActiveRecord::Migration[6.0]
  def change
    change_table :v2_zone_caches, bulk: true do |t|
      t.bigint :population, null: false
      t.decimal :area_sq_km, null: false
    end
  end
end
