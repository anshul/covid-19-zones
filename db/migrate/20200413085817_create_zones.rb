# frozen_string_literal: true

class CreateZones < ActiveRecord::Migration[6.0]
  def change
    create_table :zones do |t|
      t.string :type, null: false
      t.string :slug, null: false
      t.string :code, null: false

      t.string :name, null: false
      t.string :parent_zone
      t.string :zone_md, default: "", null: false
      t.jsonb :details, default: "{}", null: false

      t.timestamps

      t.index :slug, unique: true
      t.index :code, unique: true
      t.index :type
      t.index :name
    end
  end
end
