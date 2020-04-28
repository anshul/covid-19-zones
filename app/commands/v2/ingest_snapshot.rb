# frozen_string_literal: true

module V2
  class IngestSnapshot < ::BaseCommand
    def self.perform_task
      log "Ingesting latest snapshots for #{::V2::Origin.count} origins"
      ::V2::Origin.in_batches.all? do |rel|
        rel.pluck(:code).all? do |code|
          snapshot_id = ::V2::Snapshot.where(origin_code: code).order(downloaded_at: :desc).limit(1).pluck(:id).first
          log "* #{code}: No snapshots found, skipping..." unless snapshot_id
          next unless snapshot_id

          cmd = new(snapshot_id: snapshot_id)
          out = cmd.call
          out ? log("   > #{code}: Snapshot ##{snapshot_id} ingested.", color: :green) : log("  > Snapshot ##{snapshot_id} failed: #{cmd.error_message}", color: :red)
          out
        end
      end
      log "Done!"
    end

    ORIGIN_PARSER_MAP = {
      "covid19-india-raw-data"              => ::V2::Parsers::Covid19IndiaRawParser,
      "covid19-india-deaths-and-recoveries" => ::V2::Parsers::Covid19IndiaDeathsAndRecoveriesParser,
      "covid19-india-state-districts"       => ::V2::Parsers::Covid19IndiaStateDistrictsParser
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

      ::V2::Stream.where(origin_code: snapshot.origin_code).delete_all
      import(::V2::Stream, streams, on_duplicate_key_update: ::V2::Stream.on_duplicate_key_options, batch_size: 500)
    end
  end
end
