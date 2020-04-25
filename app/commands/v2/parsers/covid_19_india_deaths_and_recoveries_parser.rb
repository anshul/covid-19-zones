# frozen_string_literal: true

module V2
  module Parsers
    class Covid19IndiaDeathsAndRecoveriesParser < ::BaseCommand
      attr_reader :snapshot, :raw_data, :streams, :country_code
      def initialize(snapshot_id:)
        @snapshot = ::V2::Snapshot.find(snapshot_id)
        @raw_data = snapshot.data["deaths_recoveries"]
        @country_code = "in"
        @streams = []
      end

      def run
        parse_streams
      end

      def parse_streams
        rows = raw_data.filter { |row| row["date"].present? }

        compute_rec_and_fat_time_series_for!(unit_code: country_code, rows: rows)

        grouped_by_state = rows.filter { |row| row["state"].present? }.group_by { |row| row["state"] }
        grouped_by_state.map { |state_name, s_rows| process_state(state_name: state_name, rows: s_rows) }
      end

      STATE_CODE_MAP = {
        "andaman and nicobar islands" => "in/an"
      }.freeze
      def process_state(state_name:, rows:)
        unit_code = STATE_CODE_MAP[state_name.downcase] || states_map[state_name.downcase]&.code
        return true if unit_code.blank?

        compute_rec_and_fat_time_series_for!(unit_code: unit_code, rows: rows)

        grouped_by_district = rows.filter { |row| row["district"].present? }.group_by { |row| row["district"] }
        grouped_by_district.map { |district_name, d_rows| process_district(state_code: unit_code, district_name: district_name, rows: d_rows) }
      end

      def process_district(state_code:, district_name:, rows:)
        return true unless districts_grouped_by_parent_code[state_code]&.key?(district_name.downcase)

        unit_code = districts_grouped_by_parent_code[state_code][district_name.downcase].code
        compute_rec_and_fat_time_series_for!(unit_code: unit_code, rows: rows)
      end

      def compute_rec_and_fat_time_series_for!(unit_code:, rows:)
        @streams << stream_for(unit_code: unit_code, category: "recovery", time_series: recovery_time_series_for(rows))
        @streams << stream_for(unit_code: unit_code, category: "fatality", time_series: fatality_time_series_for(rows))
      end

      def states_map
        @states_map ||= base_unit_query.where(category: "state").index_by { |state| state.name.downcase }
      end

      def districts_grouped_by_parent_code
        @districts_grouped_by_parent_code ||= base_unit_query.where(category: "district").group_by(&:parent_code).transform_values { |districts| districts.index_by { |dist| dist.name.downcase } }
      end

      def recovery_time_series_for(rows)
        rows.filter { |row| row["patientstatus"] == "Recovered" }.group_by { |row| Date.parse(row["date"]) }.transform_values(&:count)
      end

      def fatality_time_series_for(rows)
        rows.filter { |row| row["patientstatus"] == "Deceased" }.group_by { |row| Date.parse(row["date"]) }.transform_values(&:count)
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
