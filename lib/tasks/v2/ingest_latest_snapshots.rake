# frozen_string_literal: true

namespace :v2 do
  desc "Tries to ingest latest snapshots for all origins"
  task ingest_latest_snapshots: :environment do
    origins = ::V2::Origin.all

    puts "Ingesting latest snapshots for #{origins.count} origins"
    origins.each do |origin|
      latest_snapshot = ::V2::Snapshot.where(origin_code: origin.code).order(downloaded_at: :desc).first

      puts "* No snapshots for origin #{origin.code}, skipping..." if latest_snapshot.blank?

      cmd = ::V2::IngestSnapshot.new(snapshot_id: latest_snapshot.id)
      next puts("* Ingestion failed for #{origin.code}, err: #{cmd.error_message}") unless cmd.run

      puts "* #{origin.code} succeeded"
    end
  end
end
