# frozen_string_literal: true

class AddColumnsToV2Streams < ActiveRecord::Migration[6.0]
  def change
    change_table :v2_streams, bulk: true do |t|
      t.datetime :downloaded_at, index: true
      t.text :attribution_md, index: true
    end
  end
end
