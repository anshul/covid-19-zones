# frozen_string_literal: true

namespace :v2 do
  desc "Fetch all origin with json data"
  task download_json_origins: :environment do
    ActiveRecord::Base.logger = nil if Rails.env.production?
    origins = ::V2::Origin.where(data_category: "json")
    origins.each do |origin|
      ::V2::Downloaders::DownloadJson.perform_task(origin_code: origin.code)
    end
  end
end
