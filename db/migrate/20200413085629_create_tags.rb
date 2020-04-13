# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.string :slug, null: false
      t.string :code, null: false
      t.string :name
      t.string :tag_md

      t.timestamps

      t.index :slug, unique: true
      t.index :tag_md
    end
  end
end
