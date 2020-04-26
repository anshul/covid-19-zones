# frozen_string_literal: true

module V2
  module Parsers
    class BaseParser < ::BaseCommand
      attr_reader :snapshot, :streams, :country_code
      def initialize(snapshot_id:, country_code: "in")
        @snapshot = ::V2::Snapshot.includes(:origin).find(snapshot_id)
        @country_code = country_code
        @streams = []
      end

      def run
        parse_streams
      rescue StandardError => e
        add_error("Failed to parse snapshot ##{snapshot.id} due to #{e.class}, #{e.message} (in #{self.class})")
      end

      private

      def dateify(date)
        Date.parse(date.to_s.strip)
      rescue Date::Error => e
        raise ArgumentError, "#{e.class} #{e.message} <for #{dt.inspect}>"
      end
    end
  end
end
