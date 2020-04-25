# frozen_string_literal: true

class CreateV2Facts < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_facts do |t|
      t.string :entity_slug, null: false
      t.string :entity_type, null: false
      t.string :fact_type, null: false
      t.string :signature, null: false
      t.integer :sequence, null: false
      t.jsonb :details, null: false, default: {}
      t.datetime :happened_at, null: false

      t.timestamps
    end

    add_index :v2_facts, %i[entity_slug sequence], unique: true
    add_index :v2_facts, :fact_type
    add_index :v2_facts, :happened_at
  end
end
