# frozen_string_literal: true

class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.string :slug, null: false
      t.string :code, null: false
      t.string :source, null: false
      t.string :external_code, null: false

      t.string :zone_code, null: false
      t.string :external_signature, null: false
      t.jsonb :external_details, default: {}, null: false

      t.date :announced_on, null: false
      t.string :status, null: false
      t.date :status_changed_on

      t.string :name
      t.string :gender
      t.string :age

      t.datetime :first_imported_at
      t.datetime :last_imported_at

      t.timestamps

      t.index :slug, unique: true
      t.index :code, unique: true
      t.index %i[external_code source], unique: true
      t.index :zone_code
      t.index :status
    end
  end
end
