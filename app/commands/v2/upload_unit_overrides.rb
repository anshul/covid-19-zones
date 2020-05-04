# frozen_string_literal: true

module V2
  class UploadUnitOverrides < ::BaseCommand
    attr_reader :override_code, :override, :unit, :csv, :parsed_csv
    def initialize(override_code:, csv:)
      @override_code = override_code
      @override = ::V2::Override.find_by(code: override_code)
      @unit = override&.unit
      @csv = csv
    end

    def run
      return add_error "Override does not exist" if override.blank?
      return add_error "#{unit.category.humanize} cannot be overriden" unless unit.overridable?

      parse_csv &&
        validate_csv &&
        record_fact(:override_details_uploaded, entity_type: :unit, entity_slug: override_code, details: { override_details: parsed_csv.map(&:to_h).map { |row| transform_row(row) } })
    end

    def parse_csv
      @parsed_csv ||= CSV.parse(csv, headers: true)
    rescue CSV::MalformedCSVError => e
      add_error("Badly formatted csv: #{e.message}")
    end

    CSV_COLUMNS = %w[unit_code category date value].freeze
    def validate_csv
      missing_headers = CSV_COLUMNS - parsed_csv.headers
      extra_headers = parsed_csv.headers - CSV_COLUMNS

      return add_error "Missing headers: #{missing_headers.join(', ')}" if missing_headers.present?
      return add_error "Extra headers: #{extra_headers.join(', ')}" if extra_headers.present?

      parsed_csv.each.with_index.all? { |row, idx| validate_row(row, idx + 1) }
    end

    def validate_row(row, idx)
      return add_error "Row ##{idx}: Invalid unit_code #{row['unit_code']}" unless valid_unit_codes.include? row["unit_code"]
      return add_error "Row ##{idx}: Invalid category: #{row['category']}" unless ::V2::Stream::CATEGORIES.include? row["category"]

      true
    end

    def transform_row(row)
      {
        **row,
        "date"  => Date.parse(row["date"]),
        "value" => row["value"].to_i
      }
    end

    def valid_unit_codes
      @valid_unit_codes ||= override.overridable_units.pluck(:code)
    end
  end
end
