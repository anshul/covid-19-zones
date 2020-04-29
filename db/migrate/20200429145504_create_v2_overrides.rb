# frozen_string_literal: true

class CreateV2Overrides < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_overrides do |t|
      t.string :code, null: false
      t.jsonb :override_details, array: true, null: false, default: []
      t.jsonb :events, array: true, null: false, default: []
      t.jsonb :chart_events, array: true, null: false, default: []
      t.jsonb :hotspots, array: true, null: false, default: []
      t.string :maintainer

      t.timestamps
    end

    add_index :v2_overrides, :code, unique: true
    add_index :v2_overrides, :maintainer
  end
end
