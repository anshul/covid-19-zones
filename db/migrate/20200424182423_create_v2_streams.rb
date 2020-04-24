# frozen_string_literal: true

class CreateV2Streams < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_streams do |t|
      t.string :code, null: false
      t.string :type, null: false

      t.string :unit_code, null: false
      t.string :origin_code, null: false
      t.jsonb :time_series, null: false, default: {}
      t.date :dated, null: false
      t.integer :priority, null: false, default: 50
      t.string :md, null: false, default: ""

      t.references :snapshot_id, null: false

      t.timestamps
    end

    add_index :v2_streams, :code, unique: true, name: "v2_stream_unique"
    add_index :v2_streams, %i[type unit_code origin_code], unique: true, name: "v2_stream_signature_unique"
    add_index :v2_streams, :dated
    add_index :v2_streams, :priority
  end
end
