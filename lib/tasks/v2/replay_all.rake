# frozen_string_literal: true

namespace :v2 do
  desc "Replay all v2 facts"
  task replay_all: :environment do
    ActiveRecord::Base.logger = nil if Rails.env.production?
    ::V2::ReplayUnit.perform_replay_all_task
  end
end
