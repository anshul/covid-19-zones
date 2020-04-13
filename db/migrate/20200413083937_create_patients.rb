# frozen_string_literal: true

class CreatePatients < ActiveRecord::Migration[6.0]
  def change
    create_table :patients do |t|
      t.string :patient_number, null: false
      t.string :status, null: false
      t.string :name
      t.string :tagged_district
      t.string :tagged_city
      t.string :tagged_state
      t.string :tagged_country
      t.string :gender
      t.string :age
      t.string :nationality

      t.jsonb :sources

      t.date :date_announced, null: false
      t.date :date_status_changed
      t.date :type_of_transmission

      t.timestamps

      t.index :patient_number, unique: true
      t.index :tagged_city
      t.index :tagged_country
      t.index :tagged_district
      t.index :tagged_state
      t.index :status
    end
  end
end
