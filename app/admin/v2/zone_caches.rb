# frozen_string_literal: true

ActiveAdmin.register ::V2::ZoneCache, as: "ZoneComputation" do
  menu label: "Zone computations", priority: 15
  includes :zone

  scope :all, default: true do |caches|
    caches.joins(:zone)
  end

  ::V2::Zone::CATEGORIES.each do |cat|
    scope cat.capitalize, group: :category do |caches|
      caches.joins(:zone).where("v2_zones.category" => cat)
    end
  end

  index do
    column :code do |cache|
      link_to cache.code, v2_zone_computation_path(cache)
    end
    column :zone, &:zone
    column :category do |cache|
      cache.zone.category.capitalize
    end
    column :published do |cache|
      !!cache.zone.published_at
    end
    column "actives", :current_actives
    column "infections", :cumulative_infections
    column "recoveries", :cumulative_recoveries
    column "fatalities", :cumulative_fatalities
    column "tests", :cumulative_tests
    column :start
    column :stop
    column :attributions_md, label: "attributions"
    actions
  end

  show do
    attributes_table do
      row :zone
      row :aliases do |cache|
        cache.zone.aliases
      end
      row :unit_codes
      row :as_of
      row :start
      row :stop
      row :attributions_md
      row :cached_at
      row :streams do |cache|
        table_for cache.streams ? cache.streams.map { |k, h| h.keys.map { |u| [k, u] } }.sum.sort : [] do
          column "time_series" do |k, _u|
            k
          end
          column "units" do |_k, u|
            ::V2::Unit[u]
          end
          column "series" do |k, u|
            code, sid = cache.streams[k][u]&.values_at("code", "snapshot_id") || []
            stream = ::V2::Stream[code]
            (stream.snapshot_id == sid ? stream : "expired") if stream
          end
          column "latest series" do |k, u|
            code, = cache.streams[k][u]&.values_at("code") || []
            ::V2::Stream[code]
          end
          column "latest total" do |k, u|
            code, = cache.streams[k][u]&.values_at("code") || []
            ::V2::Stream[code]&.cumulative_count.to_i
          end

          column "snapshot" do |k, u|
            sid, = cache.streams[k][u]&.values_at("snapshot_id") || []
            ::V2::Snapshot.find_by(id: sid)
          end
        end
      end
      row :totals do |cache|
        table_for [cache] do
          column "actives", :current_actives
          column "infections", :cumulative_infections
          column "recoveries", :cumulative_recoveries
          column "fatalities", :cumulative_fatalities
          column "tests", :cumulative_tests
        end
      end
      row :time_series do |cache|
        table_for((cache.start..cache.stop).to_a.reverse) do
          column "date" do |dt|
            dt
          end
          column "actives" do |dt|
            cache.ts_actives[dt.to_s]
          end
          column "infections" do |dt|
            cache.ts_infections[dt.to_s]
          end
          column "recoveries" do |dt|
            cache.ts_recoveries[dt.to_s]
          end
          column "fatalities" do |dt|
            cache.ts_fatalities[dt.to_s]
          end
          column "tests" do |dt|
            cache.ts_tests[dt.to_s]
          end
        end
      end
    end
  end

  actions :index, :show
end
