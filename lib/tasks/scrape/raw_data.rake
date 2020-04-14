# frozen_string_literal: true

namespace :scrape do
  desc "Scrape raw data from covid19india.org"
  task raw_data: :environment do
    cmd = ::FetchRawData.new
    cmd.call_endpoint
  end
end
