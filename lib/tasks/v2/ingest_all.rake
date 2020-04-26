# frozen_string_literal: true

namespace :v2 do
  desc "Tries to ingest latest snapshots for all origins"
  task ingest_all: :environment do
    ::V2::IngestSnapshot.perform_task
  end
end
