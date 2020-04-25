# frozen_string_literal: true

class CreateV2Origins < ActiveRecord::Migration[6.0]
  def change
    create_table :v2_origins do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :attribution_text, null: false
      t.string :source_name, null: false
      t.string :source_subname, null: false
      t.string :md, null: false, default: ""

      t.timestamps
    end

    add_index :v2_origins, :code, unique: true
    add_index :v2_origins, :name
  end
end
