# frozen_string_literal: true

class AddColumnsToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :name
      t.string :role, null: false, default: "contributor"
      t.string :github_handle
      t.string :twitter_handle
      t.text :bio_md
    end
  end
end
