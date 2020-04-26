class AddColumnsToZoneCaches < ActiveRecord::Migration[6.0]
  def change
    change_table :v2_zone_caches, bulk: true do |t|
      t.jsonb :streams, default: {}, null: false
    end
  end
end
