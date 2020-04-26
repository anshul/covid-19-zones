# frozen_string_literal: true

namespace :v2 do
  desc "Update caches of all zones"
  task cache_all: :environment do
    ::V2::RefreshCache.perform_task
  end
end
