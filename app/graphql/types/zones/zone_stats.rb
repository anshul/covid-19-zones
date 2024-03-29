# frozen_string_literal: true

module Types
  module Zones
    class ZoneStats < Types::BaseObject
      field :zone, ::Types::Zones::Zone, null: false
      field :as_of, String, null: false
      field :total_cases, Int, null: false
      field :cum_cases, ::Types::LineChartType, null: false
      field :new_cases, ::Types::LineChartType, null: false
    end
  end
end
