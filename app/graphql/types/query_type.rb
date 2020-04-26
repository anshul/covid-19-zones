# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :zone, ::Types::Zones::Zone, null: false, description: "Zone daily_chart" do
      argument :slug, String, required: true
    end

    field :zones_list, [::Types::Zones::Zone], null: false, description: "List of all zones" do
      argument :search_query, String, required: false
    end

    field :home, ::Types::Home::HomeData, null: false

    field :zone_stats, ::Types::Zones::ZoneStats, null: true do
      argument :code, String, required: true
    end

    field :compare, ::Types::Zones::CompareStats, null: true do
      argument :codes, [String], required: true
    end

    def zone(slug:)
      ::Zone.find_by(slug: slug)
    end

    def zones_list(search_query:)
      ::V2::Zone.joins(:cache).includes(:cache).order(cumulative_infections: :desc).where("search_key LIKE ? OR search_key LIKE ?", "#{search_query.parameterize}%", "%-#{search_query.parameterize}%").limit(20)
    end

    def home
      confirmed = ::TimeSeriesPoint.where(target_code: "in").sum(:announced)
      {
        cases: [
          { label: "Active", name: "active", value: confirmed - recovered - deceased }
        ]
      }
    end

    def zone_stats(code:)
      zone = ::V2::Zone.find_by(code: code)
      return nil unless zone

      cache = zone.cache
      index = cache.chart_index
      v_daily = cache.daily_infections(idx: index)
      v_daily_sma5 = v_daily.rolling_mean(5)
      v_total = cache.total_infections(idx: index)
      v_total_ema5 = v_total.ema(5)

      daily_key = zone.name
      daily_sma_key = "#{zone.name} - 5 day moving average"
      chart_daily = index.entries.map(&:to_date).map do |date|
        {
          date: date.strftime("%b %d"),
          daily_key => v_daily[date.to_s].to_i,
          daily_sma_key => v_daily_sma5[date.to_s].to_i
        }
      end

      total_key = zone.name
      total_ema_key = "#{zone.name} - 5 day exp average"
      chart_total = index.entries.map(&:to_date).map do |date|
        {
          date: date.strftime("%b %d"),
          total_key => v_total[date.to_s].to_i,
          total_ema_key => v_total_ema5[date.to_s].to_i
        }
      end

      {
        zone:        zone,
        total_cases: cache.cumulative_infections,
        as_of:       cache.as_of.strftime("%d %B %Y, %I:%M %P %Z"),
        new_cases:   {
          x_axis_key: "date",
          line_keys:  [daily_key, daily_sma_key],
          data:       chart_daily
        },
        cum_cases:   {
          x_axis_key: "date",
          line_keys:  [total_key, total_ema_key],
          data:       chart_total
        }
      }
    end

    def compare(codes:)
      zones = ::V2::Zone.includes(:cache).where(code: codes)
      return nil unless zones.count == codes.count

      caches = zones.map(&:cache)
      series_start = caches.map(&:start).min
      index = TimeSeriesPoint.index(start: [series_start, 8.days.ago].min, stop: 1.day.ago)
      v_daily = {}
      v_total = {}

      zones.map do |zone|
        v_daily[zone.name] = zone.cache.daily_infections(idx: index)
        v_total[zone.name] = zone.cache.total_infections(idx: index)
      end

      daily_chart = index.entries.map(&:to_date).map do |date|
        h = { date: date.strftime("%b %d") }
        zones.each do |zone|
          h[zone.name] = v_daily[zone.name][date.to_s].to_i
        end
        h
      end

      total_chart = index.entries.map(&:to_date).map do |date|
        h = { date: date.strftime("%b %d") }
        zones.each do |zone|
          h[zone.name] = v_total[zone.name][date.to_s].to_i
        end
        h
      end

      {
        zones:       zones,
        total_cases: zones.map { |zone| { zone_name: zone.name, count: zone.cache.cumulative_infections, as_of: zone.cache.as_of.strftime("%d %B %Y, %I:%M %P %Z") } },
        cum_cases:   {
          x_axis_key: "date",
          line_keys:  zones.map(&:name),
          data:       total_chart
        },
        new_cases:   {
          x_axis_key: "date",
          line_keys:  zones.map(&:name),
          data:       daily_chart
        }
      }
    end
  end
end
