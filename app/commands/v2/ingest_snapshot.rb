# frozen_string_literal: true

module V2
  class IngestSnapshot < ::BaseCommand
    ORIGIN_PARSER_MAP = {
      "covid19-india-raw-data"              => ::V2::Parsers::Covid19IndiaRawParser,
      "covid19-india-deaths-and-recoveries" => ::V2::Parsers::Covid19IndiaDeathsAndRecoveriesParser
    }.freeze

    attr_reader :snapshot
    def initialize(snapshot_id:)
      @snapshot = ::V2::Snapshot.find(snapshot_id)
    end

    def run
      return add_error("Snapshot does not exist") if snapshot.blank?

      parser_klass = ORIGIN_PARSER_MAP[snapshot.origin_code]
      return add_error("No parser present for origin #{snapshot.origin_code}") if parser_klass.blank?

      parser = parser_klass.new(snapshot_id: snapshot.id)
      return add_error("Parsing failed, err: #{parser.error_message}") unless parser.run

      streams = parser.streams
      streams.each(&:refresh_meta!)

      ::V2::Stream.import(streams, on_duplicate_key_update: ::V2::Stream.on_duplicate_key_options, batch_size: 500)
    end
  end
end
