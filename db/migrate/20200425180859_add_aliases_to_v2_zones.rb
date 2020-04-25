# frozen_string_literal: true

class AddAliasesToV2Zones < ActiveRecord::Migration[6.0]
  def change
    change_table :v2_zones, bulk: true do |t|
      t.string :aliases, array: true, null: false, default: []
      t.string :search_key, null: false, default: ""
    end

    add_index :v2_zones, :search_key
  end
end
