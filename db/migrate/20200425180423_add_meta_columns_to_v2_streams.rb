# frozen_string_literal: true

class AddMetaColumnsToV2Streams < ActiveRecord::Migration[6.0]
  def change
    change_table :v2_streams, bulk: true do |t|
      t.decimal :min_count, precision: 14, scale: 2, null: false
      t.decimal :max_count, precision: 14, scale: 2, null: false
      t.decimal :cumulative_count, precision: 14, scale: 2, null: false
      t.datetime :min_date, null: false
      t.datetime :max_date, null: false
    end

    add_index :v2_streams, :min_count
    add_index :v2_streams, :max_count
    add_index :v2_streams, :cumulative_count
    add_index :v2_streams, :min_date
    add_index :v2_streams, :max_date
  end
end
