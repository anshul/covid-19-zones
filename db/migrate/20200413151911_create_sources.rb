# frozen_string_literal: true

class CreateSources < ActiveRecord::Migration[6.0]
  def change
    create_table :sources do |t|
      t.string :slug, null: false
      t.string :code, null: false
      t.string :name, null: false
      t.jsonb :details, null: false, default: {}

      t.timestamps

      t.index :slug, unique: true
      t.index :code, unique: true
    end
  end
end
