# frozen_string_literal: true

class CreateTaggings < ActiveRecord::Migration[6.0]
  def change
    create_table :taggings do |t|
      t.string :taggable_tag
      t.references :taggable, polymorphic: true

      t.timestamps
    end
  end
end
