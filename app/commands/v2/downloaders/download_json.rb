# frozen_string_literal: true

module V2
  module Downloaders
    class DownloadJson < ::BaseCommand
      def self.perform_task(origin_code:)
        new(origin_code: origin_code).call_with_transaction
      end

      attr_reader :origin, :origin_code, :response, :response_json
      def initialize(origin_code:)
        @origin_code = origin_code.to_s
        @origin = ::V2::Origin.find_by(code: origin_code)
      end

      def run
        return add_error("Origin does not exist") if origin.blank?
        return add_error("Origin does not have a valid source url") if origin.source_url.blank?

        fetch_data &&
          create_snapshot_if_needed
      end

      def fetch_data
        log "* Calling #{origin.source_url}"
        @response = ::Excon.get(origin.source_url)
        @response_json = JSON.parse(response.body)
        unless response.status == 200
          log "    > Got #{response.status}. Aborting..."
          return false
        end
        log "    > Got #{response.status}. Parsing"
      end

      def create_snapshot_if_needed
        return log("Data hasn't changed, skipping...") if ::V2::Snapshot.exists?(origin_code: origin_code, signature: signature)

        snapshot = ::V2::Snapshot.find_or_initialize_by(origin_code: origin_code)
        snapshot.assign_attributes(
          signature:     signature,
          data:          response_json,
          downloaded_at: t_start
        )

        return log("Failed to save snapshot, err: #{snapshot.errors.full_messages.to_sentence}", return_value: false) unless snapshot.save

        true
      end

      def signature
        @signature ||= Digest::MD5.hexdigest(JSON.generate(response_json.deep_sort))
      end
    end
  end
end
