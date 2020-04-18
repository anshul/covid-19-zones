# frozen_string_literal: true

class DataSnapshots < ActiveRecord::Migration[6.0]
  def change
    create_table :data_snapshots do |t|
      t.string :source, null: false
      t.string :api_code, null: false
      t.string :signature, null: false
      t.string :job_code, null: false
      t.jsonb :raw_data, default: {}
      t.datetime :downloaded_at, null: false

      t.timestamps

      t.index %i[source api_code signature], unique: true, name: "data_snapshots_uniq"
      t.index :job_code
      t.index :downloaded_at
    end
  end
end
