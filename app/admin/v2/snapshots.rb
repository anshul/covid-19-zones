# frozen_string_literal: true

ActiveAdmin.register ::V2::Snapshot do
  menu label: "Snapshots (v2)", priority: 90
  scope :all, default: true
  includes :origin
  config.per_page = 10

  actions :index, :show
  index do
    column :code do |snapshot|
      link_to snapshot.id, v2_v2_snapshot_path(snapshot)
    end
    column :streams do |snapshot|
      link_to "#{snapshot.streams.count} current time series", v2_v2_streams_path(q: { snapshot_id_eq: snapshot.id })
    end
    column :origin

    column :downloaded_at
    column :md5, &:signature
    actions
  end
  show do
    attributes_table do
      row :id
      row :origin
      row :origin_code
      row :signature
      row :rows do |snapshot|
        snapshot.rows.count
      end
      row :keys do |snapshot|
        snapshot.rows.empty? ? "" : snapshot.rows.first.keys
      end
      row :last_2 do |snapshot|
        pre do
          JSON.pretty_generate(snapshot.rows.last(2))
        end
      end
      row :first_2 do |snapshot|
        pre do
          JSON.pretty_generate(snapshot.rows.first(2))
        end
      end

      row :stats_a do |snapshot|
        table_for((0..40).to_a) do
          column "Rank" do |i|
            i + 1
          end
          snapshot.interesting_keys.each do |k|
            column k do |i|
              snapshot.stats[k.join(";")][i]
            end
          end
        end
      end
      row :stats_b do |snapshot|
        table_for((0..10).to_a) do
          column "Rank" do |i|
            i + 1
          end
          snapshot.interesting_keys.flatten[0, 5].each do |k|
            column k do |i|
              snapshot.stats[k][i]
            end
          end
        end
      end
      row :stats_c do |snapshot|
        table_for((0..10).to_a) do
          column "Rank" do |i|
            i + 1
          end
          snapshot.other_keys[0, 5].each do |k|
            column k do |i|
              snapshot.stats[k.join(";")][i]
            end
          end
        end
      end
      row :stats_d do |snapshot|
        table_for((0..10).to_a) do
          column "Rank" do |i|
            i + 1
          end
          snapshot.other_keys[5, 10]&.each do |k|
            column k do |i|
              snapshot.stats[k.join(";")][i]
            end
          end
        end
      end
    end
  end

  filter :origin
  filter :downloaded_at
end
