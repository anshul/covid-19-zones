# frozen_string_literal: true

namespace :fetch do
  desc "Fetch data from www.mohfw.gov.in/dashboard/data/data.json"
  task mohfw: :environment do
    ::FetchMohfw.perform_task
  end
end
