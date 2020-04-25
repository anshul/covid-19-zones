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

    field :zone_stats, ::Types::Zones::ZoneStats, null: false do
      argument :code, String, required: true
    end

    field :compare, ::Types::Zones::CompareStats, null: false do
      argument :codes, [String], required: true
    end

    def zone(slug:)
      ::Zone.find_by(slug: slug)
    end

    def zones_list(search_query:)
      ::Zone.where("search_name LIKE ?", "%#{search_query.parameterize}%").where(type: %w[District State Country]).distinct(:slug).order(:name).limit(20)
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
      series_start = TimeSeriesPoint.where("target_code like ?", "#{zone.code}%").where(target_type: zone.type).minimum(:dated)

      index = TimeSeriesPoint.index(start: series_start || Time.zone.today - 14.days, stop: 1.day.ago)
      announced_vector = TimeSeriesPoint.vector(target: zone, field: "announced", index: index)
      announced_vector_sma5 = announced_vector.rolling_mean(5)

      new_cases_sma_key = "#{zone.name} moving avg (5 days)"
      new_cases_daily = index.entries.map(&:to_date).map do |date|
        {
          date: date.strftime("%b %d"),
          zone.name => announced_vector[date.to_s].to_i,
          new_cases_sma_key => announced_vector_sma5[date.to_s].to_i
        }
      end

      {
        zone:        zone,
        total_cases: announced_vector.sum,
        as_of:       index.entries.last.strftime("%d %B, %Y"),
        new_cases:   {
          x_axis_key: "date",
          line_keys:  [zone.name, new_cases_sma_key],
          data:       new_cases_daily
        }
      }
    end

    def compare(codes:)
      zones = Zone.where(code: codes)
      series_start = TimeSeriesPoint.where(target_code: codes).minimum(:dated)
      index = TimeSeriesPoint.index(start: series_start || Time.zone.today - 14.days, stop: Time.zone.today)
      announced_vectors = {}
      zones.map do |zone|
        announced_vectors[zone.name.to_s] = TimeSeriesPoint.vector(target: zone, field: "announced", index: index)
      end

      new_cases_daily = index.entries.map(&:to_date).map do |date|
        data = {}
        announced_vectors.keys.map do |key|
          data[key] = announced_vectors[key][date.to_s].to_i
        end
        { date: date.strftime("%b %d") }.merge(data)
      end
      {
        zones:       zones,
        total_cases: announced_vectors.keys.map { |key| { zone_name: key, count: announced_vectors[key].sum } },
        new_cases:   {
          x_axis_key: "date",
          line_keys:  zones.map(&:name),
          data:       new_cases_daily
        }
      }
    end
  end
end
