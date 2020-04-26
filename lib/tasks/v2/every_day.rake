# frozen_string_literal: true

namespace :v2 do
  desc "Task to call from the scheduler every day"
  task every_day: %i[replay_all]
end
