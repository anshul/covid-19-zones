# frozen_string_literal: true

namespace :v2 do
  desc "Task to call from the scheduler every hour"
  task every_hour: %i[download_all ingest_all cache_all]
end
