# frozen_string_literal: true

namespace :recompute do
  desc "Recompute time series"
  task all: :environment do
    ::Recompute.perform_task
  end
end
