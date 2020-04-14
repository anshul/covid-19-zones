# frozen_string_literal: true

class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.string :slug, null: false
      t.string :code, null: false
      t.string :external_code, null: false
      t.string :status, null: false
      t.string :zone_code, null: false
      t.string :source, null: false

      t.string :name
      t.string :gender
      t.string :age
      t.string :nationality
      t.string :transmission_type

      t.date :announced_on, null: false
      t.date :status_changed_on

      t.timestamps

      t.index :slug, unique: true
      t.index :code, unique: true
      t.index %i[external_code source], unique: true
      t.index :zone_code
      t.index :status
    end
  end
end
