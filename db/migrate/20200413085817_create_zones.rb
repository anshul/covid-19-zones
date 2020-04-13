# frozen_string_literal: true

class CreateZones < ActiveRecord::Migration[6.0]
  def change
    create_table :zones do |t|
      t.string :slug, null: false
      t.string :name
      t.string :zone_md
      t.string :tag_slug

      t.timestamps

      t.index :slug, unique: true
      t.index :zone_md
      t.index :tag_slug
    end
  end
end
