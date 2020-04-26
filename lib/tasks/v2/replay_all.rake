# frozen_string_literal: true

namespace :v2 do
  desc "Replay all v2 facts"
  task replay_all: :environment do
    ::V2::ReplayUnit.perform_replay_all_task
  end
end
