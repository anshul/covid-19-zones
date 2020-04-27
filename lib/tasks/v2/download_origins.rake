# frozen_string_literal: true

namespace :v2 do
  desc "Fetch all origin data"
  task download_origins: :environment do
    ActiveRecord::Base.logger = nil if Rails.env.production?
    origins = ::V2::Origin
    origins.each do |origin|
      klass = "v2/downloaders/download_#{origin.download_category}"
      klass.constantize.perform_task(origin_code: origin.code)
    end
  end
end
