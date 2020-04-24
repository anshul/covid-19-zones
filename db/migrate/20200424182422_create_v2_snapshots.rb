# frozen_string_literal: true

class CreateV2Snapshots < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_snapshots do |t|
      t.string :unit_code, null: false
      t.string :origin_code, null: false
      t.string :snapshot_type, null: false

      t.string :signature, null: false
      t.jsonb :data, null: false
      t.datetime :downloaded_at, null: false

      t.timestamps
    end

    add_index :v2_snapshots, %i[unit_code origin_code snapshot_type signature], unique: true, name: "v2_snapshots_signature_unique"
    add_index :v2_snapshots, :downloaded_at
  end
end
