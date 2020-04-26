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

  filter :origin
  filter :downloaded_at
end
