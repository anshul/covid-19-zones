# frozen_string_literal: true

module V2
  class BackfillOverrides < BaseCommand
    def self.perform_task
      new.call_with_transaction
    end

    def run
      backfill_country &&
        backfill_states
    end

    def backfill_country
      cmd = ::V2::UploadUnitOverrides.new(override_code: country.override.code, csv: csv_for([country.code]))
      cmd.call(errors: errors)
    end

    def backfill_states
      states.all? do |state|
        cmd = ::V2::UploadUnitOverrides.new(override_code: state.override.code, csv: csv_for([state.code, *state.children.pluck(:code)]))
        cmd.call(errors: errors)
      end
    end

    def csv_for(unit_codes)
      range = (Time.zone.today.beginning_of_year..Date.parse("2020-04-02")).to_a.map(&:to_s)
      header = %w[unit_code category date value].join(",")
      rows = unit_codes.map do |unit_code|
        streams.keys.map do |category|
          ts = streams[category][unit_code]&.time_series
          next nil if ts.blank?

          range.map { |dt| ts[dt] ? [unit_code, category, dt, ts[dt]].join(",") : nil }.compact
        end.compact
      end.flatten

      ([header] + rows).join("\n")
    end

    def streams
      @streams ||= {
        infections: base_stream_query.where(origin_code: "covid19-india-raw-data", category: "infections").index_by(&:unit_code)
        # fatalities: base_stream_query.where(origin_code: "covid19-india-deaths-and-recoveries", category: "fatalities").index_by(&:unit_code),
        # recoveries: base_stream_query.where(origin_code: "covid19-india-deaths-and-recoveries", category: "recoveries").index_by(&:unit_code)
      }
    end

    def base_stream_query
      @base_stream_query ||= ::V2::Stream.where("unit_code like ?", "in%")
    end

    def country
      @country ||= ::V2::Unit.find_by(code: "in")
    end

    def states
      @states ||= ::V2::Unit.where(parent_code: country.code, category: "state")
    end
  end
end
