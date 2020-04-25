# frozen_string_literal: true

class CreateV2Posts < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_posts do |t|
      t.string :unit_code, null: false
      t.string :zone_code, null: false
      t.boolean :published, null: false, default: false

      t.timestamps
    end
    add_index :v2_posts, %i[unit_code zone_code], unique: true
    add_foreign_key "v2_posts", "v2_units", column: "unit_code", primary_key: "code"
    add_foreign_key "v2_posts", "v2_zones", column: "zone_code", primary_key: "code"
  end
end
