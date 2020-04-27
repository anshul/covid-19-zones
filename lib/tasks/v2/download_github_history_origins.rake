# frozen_string_literal: true

namespace :v2 do
  desc "Fetch all origin with github_history data"
  task download_github_history_origins: :environment do
    ActiveRecord::Base.logger = nil if Rails.env.production?
    origins = ::V2::Origin.where(data_category: "github_history")
    origins.each do |origin|
      ::V2::Downloaders::DownloadGithubHistory.perform_task(origin_code: origin.code)
    end
  end
end
