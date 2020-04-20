# frozen_string_literal: true

namespace :fetch do
  desc "Fetch data from master sheet"
  task master_data: :environment do
    ::FetchMasterData.perform_task
  end
end
