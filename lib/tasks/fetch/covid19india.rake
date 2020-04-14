# frozen_string_literal: true

namespace :fetch do
  desc "Fetch data from covid19india.org api"
  task covid19india: :environment do
    ::FetchCovid19india.perform_task
  end
end
