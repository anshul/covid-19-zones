# frozen_string_literal: true

class CreateV2Zones < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_zones do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :category, null: false
      t.string :parent_code
      t.text :md, null: false, default: ""
      t.string :maintainer

      t.timestamps
    end

    add_index :v2_zones, :code, unique: true
    add_index :v2_zones, :category
    add_index :v2_zones, :parent_code
  end
end
