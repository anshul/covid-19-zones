# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :zone, ::Types::Zones::Zone, null: false, description: "Zone data" do
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
      ::Zone.where("search_name LIKE ? OR search_name LIKE ?", "#{search_query.parameterize}%", "%-#{search_query.parameterize}%").where(type: %w[District State Country]).distinct(:slug).order(type: :desc, name: :asc).limit(20)
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
      zone = ::Zone.find_by(code: code)
      return nil unless zone

      series_start = TimeSeriesPoint.where("target_code like ?", "#{zone.code}%").where(target_type: zone.type).minimum(:dated)

      index = TimeSeriesPoint.index(start: series_start || Time.zone.today - 14.days, stop: 1.day.ago)
      announced_vector = TimeSeriesPoint.vector(target: zone, field: "announced", index: index)
      announced_vector_sma5 = announced_vector.rolling_mean(5)
      cum_announced_vector = announced_vector.cumsum
      cum_announce_vector_ema5 = cum_announced_vector.ema(5)

      new_cases_ma_key = "#{zone.name} - 5 day moving average"
      new_cases_daily = index.entries.map(&:to_date).map do |date|
        {
          date: date.strftime("%b %d"),
          zone.name => announced_vector[date.to_s].to_i,
          new_cases_ma_key => announced_vector_sma5[date.to_s].to_i
        }
      end

      cum_cases_ma_key = "#{zone.name} - 5 day exp average"
      cum_cases_daily = index.entries.map(&:to_date).map do |date|
        {
          date: date.strftime("%b %d"),
          zone.name => cum_announced_vector[date.to_s].to_i,
          cum_cases_ma_key => cum_announce_vector_ema5[date.to_s].to_i
        }
      end

      {
        zone:        zone,
        total_cases: announced_vector.sum,
        as_of:       index.entries.last.strftime("%d %B, %Y"),
        new_cases:   {
          x_axis_key: "date",
          line_keys:  [zone.name, new_cases_ma_key],
          data:       new_cases_daily
        },
        cum_cases:   {
          x_axis_key: "date",
          line_keys:  [zone.name, cum_cases_ma_key],
          data:       cum_cases_daily
        }
      }
    end

    def compare(codes:)
      zones = Zone.where(code: codes)
      return nil unless zones.count == codes.count

      series_start = TimeSeriesPoint.where(target_code: codes).minimum(:dated)
      index = TimeSeriesPoint.index(start: series_start || Time.zone.today - 14.days, stop: 1.day.ago)
      new_vectors = {}
      cum_vectors = {}
      zones.map do |zone|
        new_vectors[zone.name.to_s] = TimeSeriesPoint.vector(target: zone, field: "announced", index: index)
        cum_vectors[zone.name.to_s] = new_vectors[zone.name.to_s].cumsum
      end

      new_cases_daily = index.entries.map(&:to_date).map do |date|
        data = {}
        new_vectors.keys.map do |key|
          data[key] = new_vectors[key][date.to_s].to_i
        end
        { date: date.strftime("%b %d") }.merge(data)
      end
      cum_cases_daily = index.entries.map(&:to_date).map do |date|
        data = {}
        cum_vectors.keys.map do |key|
          data[key] = cum_vectors[key][date.to_s].to_i
        end
        { date: date.strftime("%b %d") }.merge(data)
      end
      as_of = index.entries.last.strftime("%d %B, %Y")
      {
        zones:       zones,
        total_cases: new_vectors.keys.map { |key| { zone_name: key, count: new_vectors[key].sum, as_of: as_of } },
        cum_cases:   {
          x_axis_key: "date",
          line_keys:  zones.map(&:name),
          data:       cum_cases_daily
        },
        new_cases:   {
          x_axis_key: "date",
          line_keys:  zones.map(&:name),
          data:       new_cases_daily
        }
      }
    end
  end
end
