# frozen_string_literal: true

class AddColumnsToV2Origins < ActiveRecord::Migration[6.0]
  def change
    change_table :v2_origins, bulk: true do |t|
      t.jsonb :details, default: {}, null: false
    end
  end
end
