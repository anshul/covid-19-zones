# frozen_string_literal: true

module V2
  module Parsers
    class Covid19IndiaStateDistrictsParser < ::V2::Parsers::BaseParser
      def parse_streams
        data = snapshot.data

        @categorized_streams = {}

        data.each do |date, state_rows|
          state_rows.each { |row| process_state(date: date, row: row) }
        end
        @streams = STREAM_CATEGORY_MAP.keys.map { |cat| @categorized_streams[cat].values }.flatten.compact
        clean_up
      end

      def clean_up
        @streams = @streams.reject { |s| s.time_series.blank? }
      end

      STATE_CODE_MAP = {
        "andaman-and-nicobar-islands" => "in/an"
      }.freeze
      def process_state(date:, row:)
        state_name = row["state"]
        unit_code = STATE_CODE_MAP[state_name.parameterize] || states_map[state_name.parameterize]&.code
        return true if unit_code.blank?

        row["districtData"].map { |district_row| process_district(date: date, state_code: unit_code, row: district_row) }
      end

      def process_district(date:, state_code:, row:)
        unit_code = districts_grouped_by_parent_code[state_code][row["district"].parameterize]&.code

        add_delta_to_streams(date: date, state_code: state_code, district_code: unit_code, delta: row["delta"])
      end

      STREAM_CATEGORY_MAP = {
        "infections" => "confirmed",
        "recoveries" => "recovered",
        "fatalities" => "deceased"
      }.freeze
      def add_delta_to_streams(date:, state_code:, district_code:, delta:)
        STREAM_CATEGORY_MAP.each do |category, delta_key|
          @categorized_streams[category] ||= {}

          next if delta[delta_key].blank?

          cat_streams = @categorized_streams[category]
          affected_unit_codes = [country_code, state_code, district_code]

          affected_unit_codes.each do |unit_code|
            next if unit_code.blank?

            cat_streams[unit_code] ||= stream_for(unit_code: unit_code, category: category, time_series: {})

            cat_streams[unit_code].time_series[dateify(date).to_s] ||= 0
            cat_streams[unit_code].time_series[dateify(date).to_s] += delta[delta_key].to_i
          end
        end
      end

      def states_map
        @states_map ||= base_unit_query.where(category: "state").index_by { |state| state.name.parameterize }
      end

      def districts_grouped_by_parent_code
        @districts_grouped_by_parent_code ||= base_unit_query.where(category: "district").group_by(&:parent_code).transform_values { |districts| districts.index_by { |dist| dist.name.parameterize } }
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
          snapshot:       snapshot,
          priority:       25
        )
      end

      def base_unit_query
        @base_unit_query ||= ::V2::Unit.where("code like ?", "#{country_code}%")
      end
    end
  end
end
