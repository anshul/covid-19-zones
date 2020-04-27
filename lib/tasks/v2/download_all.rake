# frozen_string_literal: true

namespace :v2 do
  desc "Fetch all origin data"
  task download_all: :environment do
    ActiveRecord::Base.logger = nil if Rails.env.production?
    origins = ::V2::Origin.all
    origins.each do |origin|
      klass = "v2/downloaders/download_#{origin.data_category}".classify
      klass.constantize.perform_task(origin_code: origin.code)
    end
  end
end
