# frozen_string_literal: true

class CreateV2Snapshots < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_snapshots do |t|
      t.string :origin_code, null: false

      t.string :signature, null: false
      t.jsonb :data, null: false, default: {}
      t.datetime :downloaded_at, null: false

      t.timestamps
    end

    add_index :v2_snapshots, %i[origin_code signature], unique: true, name: "v2_snapshots_signature_unique"
    add_index :v2_snapshots, :downloaded_at
  end
end
