# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs do |t|
      t.string :code, null: false
      t.string :slug, null: false
      t.string :source, null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :crashed_at
      t.bigint :update_count, null: false, default: 0
      t.jsonb :logs, array: true, null: false, default: []

      t.timestamps
    end
    add_index :jobs, :code, unique: true
    add_index :jobs, :slug, unique: true
    add_index :jobs, :source
  end
end
