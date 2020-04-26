# frozen_string_literal: true

namespace :v2 do
  desc "Tries to ingest latest snapshots for all origins"
  task ingest_all: :environment do
    ActiveRecord::Base.logger = nil if Rails.env.production?
    ::V2::IngestSnapshot.perform_task
  end
end
