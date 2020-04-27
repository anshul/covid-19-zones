# frozen_string_literal: true

namespace :v2 do
  desc "Task to call from the scheduler every 10 mins"
  task every_10m: %i[cache_all]
end
