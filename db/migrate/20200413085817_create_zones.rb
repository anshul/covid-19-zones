# frozen_string_literal: true

class CreateZones < ActiveRecord::Migration[6.0]
  def change
    create_table :zones do |t|
      t.string :slug, null: false
      t.string :code, null: false
      t.string :type, null: false

      t.string :name
      t.string :parent_zone
      t.string :zone_md

      t.timestamps

      t.index :slug, unique: true
      t.index :code, unique: true
      t.index :zone_md
    end
  end
end
