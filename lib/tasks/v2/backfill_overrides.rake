# frozen_string_literal: true

namespace :v2 do
  desc "Backfill overrides with raw data"
  task backfill_overrides: :environment do
    ActiveRecord::Base.logger = nil if Rails.env.production?
    cmd = ::V2::BackfillOverrides.new
    puts "ERR: #{cmd.error_message}" unless cmd.call
  end
end
