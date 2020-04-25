# frozen_string_literal: true

module V2
  module Parsers
    class Covid19IndiaRawParser < ::BaseCommand
      attr_reader :snapshot, :raw_data, :streams, :country_code
      def initialize(snapshot_id:)
        @snapshot = ::V2::Snapshot.find(snapshot_id)
        @raw_data = snapshot.data["raw_data"]
        @country_code = "in"
        @streams = []
      end

      def run
        parse_streams
      end

      def parse_streams
        rows = raw_data

        country_time_series = announced_time_series_for(rows)
        @streams << stream_for(unit_code: country_code, category: "announce", time_series: country_time_series)

        grouped_by_state = rows.filter { |row| row["detectedstate"].present? }.group_by { |row| row["detectedstate"] }
        grouped_by_state.map { |state_name, s_rows| process_state(state_name: state_name, rows: s_rows) }
      end

      STATE_CODE_MAP = {
        "andaman and nicobar islands" => "in/an"
      }.freeze
      def process_state(state_name:, rows:)
        unit_code = STATE_CODE_MAP[state_name.downcase] || states_map[state_name.downcase]&.code
        return true if unit_code.blank?

        state_time_series = announced_time_series_for(rows)
        @streams << stream_for(unit_code: unit_code, category: "announce", time_series: state_time_series)

        grouped_by_district = rows.filter { |row| row["detecteddistrict"].present? }.group_by { |row| row["detecteddistrict"] }
        grouped_by_district.map { |district_name, d_rows| process_district(state_code: unit_code, district_name: district_name, rows: d_rows) }
      end

      def process_district(state_code:, district_name:, rows:)
        return true unless districts_grouped_by_parent_code[state_code]&.key?(district_name.downcase)

        district_time_series = announced_time_series_for(rows)
        unit_code = districts_grouped_by_parent_code[state_code][district_name.downcase].code
        @streams << stream_for(unit_code: unit_code, category: "announce", time_series: district_time_series)
      end

      def states_map
        @states_map ||= base_unit_query.where(category: "state").index_by { |state| state.name.downcase }
      end

      def districts_grouped_by_parent_code
        @districts_grouped_by_parent_code ||= base_unit_query.where(category: "district").group_by(&:parent_code).transform_values { |districts| districts.index_by { |dist| dist.name.downcase } }
      end

      def announced_time_series_for(rows)
        rows.group_by { |row| Date.parse(row["dateannounced"]) }.transform_values(&:count)
      end

      def stream_for(unit_code:, category:, time_series:)
        ::V2::Stream.new(
          code:        "#{unit_code}|#{category}|#{snapshot.origin_code}",
          category:    category,
          unit_code:   unit_code,
          origin_code: snapshot.origin_code,
          time_series: time_series,
          dated:       snapshot.downloaded_at,
          snapshot:    snapshot
        )
      end

      def base_unit_query
        @base_unit_query ||= ::V2::Unit.where("code like ?", "#{country_code}%")
      end
    end
  end
end
