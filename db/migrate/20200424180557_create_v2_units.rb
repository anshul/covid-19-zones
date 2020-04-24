# frozen_string_literal: true

class CreateV2Units < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_units do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :category, null: false
      t.string :parent_code

      t.string :topojson_file
      t.string :topojson_key
      t.string :topojson_value
      t.jsonb :topojson_override

      t.bigint :population, null: false
      t.integer :population_year, null: false
      t.decimal :area_sq_km, null: false
      t.jsonb :details
      t.string :maintainer

      t.timestamps
    end

    add_index :v2_units, :code, unique: true
    add_index :v2_units, :category
    add_index :v2_units, :parent_code
  end
end
