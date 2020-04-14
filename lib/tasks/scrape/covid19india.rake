# frozen_string_literal: true

namespace :scrape do
  desc "Scrape data from covid19india.org api"
  task covid19india: :environment do
    ::FetchCovid19india.perform_task
  end
end
