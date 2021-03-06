# frozen_string_literal: true

module V2
  module Parsers
    class Covid19IndiaDeathsAndRecoveriesParser < ::V2::Parsers::BaseParser
      def parse_streams
        raw_data = snapshot.data["deaths_recoveries"]
        rows = raw_data.filter { |row| row["date"].present? }

        @unparsed = []
        compute_rec_and_fat_time_series_for!(unit_code: country_code, rows: rows)

        grouped_by_state = rows.filter { |row| row["state"].present? }.group_by { |row| row["state"] }
        grouped_by_state.map { |state_name, s_rows| process_state(state_name: state_name, rows: s_rows) }
        log("        > #{self.class} Failed to parse #{@unparsed.count} districts and states in #{@unparsed.map(&:last).sum} rows") unless @unparsed.empty?
        @unparsed.sort.each do |dist, state, n|
          dist.blank? ? log("          - #{state} in #{n} rows") : log("           - #{state}: #{dist} in #{n} rows")
        end
        clean_up
      end

      def clean_up
        @streams = @streams.reject { |s| s.time_series.blank? }
      end

      STATE_CODE_MAP = {
        "andamanp-and-nicobar-islands" => "in/an"
      }.freeze
      def process_state(state_name:, rows:)
        unit_code = STATE_CODE_MAP[state_name.parameterize] || states_map[state_name.parameterize]&.code
        @unparsed << ["", state_name, rows.count] if unit_code.blank?
        return true if unit_code.blank?

        compute_rec_and_fat_time_series_for!(unit_code: unit_code, rows: rows)

        grouped_by_district = rows.filter { |row| row["district"].present? }.group_by { |row| row["district"] }
        grouped_by_district.map { |district_name, d_rows| process_district(state_code: unit_code, district_name: district_name, rows: d_rows) }
      end

      def process_district(state_code:, district_name:, rows:)
        @unparsed << [district_name, state_code, rows.count] unless districts_grouped_by_parent_code[state_code]&.key?(district_name.parameterize)
        return true unless districts_grouped_by_parent_code[state_code]&.key?(district_name.parameterize)

        unit_code = districts_grouped_by_parent_code[state_code][district_name.parameterize].code
        compute_rec_and_fat_time_series_for!(unit_code: unit_code, rows: rows)
      end

      def compute_rec_and_fat_time_series_for!(unit_code:, rows:)
        @streams << stream_for(unit_code: unit_code, category: "recoveries", time_series: recovery_time_series_for(rows))
        @streams << stream_for(unit_code: unit_code, category: "fatalities", time_series: fatality_time_series_for(rows))
      end

      def states_map
        @states_map ||= base_unit_query.where(category: "state").index_by { |state| state.name.parameterize }
      end

      def districts_grouped_by_parent_code
        @districts_grouped_by_parent_code ||= base_unit_query.where(category: "district").group_by(&:parent_code).transform_values { |districts| districts.index_by { |dist| dist.name.parameterize } }
      end

      def recovery_time_series_for(rows)
        rows.filter { |row| row["patientstatus"] == "Recovered" && row["date"].strip.present? }.group_by { |row| dateify(row["date"]) }.transform_values(&:count)
      end

      def fatality_time_series_for(rows)
        rows.filter { |row| row["patientstatus"] == "Deceased" && row["date"].strip.present? }.group_by { |row| dateify(row["date"]) }.transform_values(&:count)
      end

      def stream_for(unit_code:, category:, time_series:)
        ::V2::Stream.new(
          code:           "#{unit_code}|#{category}|#{snapshot.origin_code}",
          category:       category,
          unit_code:      unit_code,
          origin_code:    snapshot.origin_code,
          downloaded_at:  snapshot.downloaded_at,
          attribution_md: snapshot.origin.attribution_text,
          time_series:    time_series,
          dated:          snapshot.downloaded_at,
          snapshot:       snapshot
        )
      end

      def base_unit_query
        @base_unit_query ||= ::V2::Unit.where("code like ?", "#{country_code}%")
      end
    end
  end
end
