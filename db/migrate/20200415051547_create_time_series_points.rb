# frozen_string_literal: true

class CreateTimeSeriesPoints < ActiveRecord::Migration[6.0]
  def change
    create_table :time_series_points do |t|
      t.date :dated
      t.string :target_code
      t.string :target_type
      t.decimal :population, precision: 14, scale: 2, null: false, default: 0
      t.decimal :area_sq_km, precision: 14, scale: 2, null: false, default: 0
      t.decimal :density, precision: 14, scale: 4, null: false, default: 0

      t.decimal :announced, precision: 14, scale: 2, null: false, default: 0
      t.decimal :recovered, precision: 14, scale: 2, null: false, default: 0
      t.decimal :deceased, precision: 14, scale: 2, null: false, default: 0

      t.timestamps
    end
    add_index :time_series_points, %i[dated target_code target_type], unique: true, name: "time_series_points_uniq"
  end
end
