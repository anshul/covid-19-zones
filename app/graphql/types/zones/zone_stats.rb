# frozen_string_literal: true

module Types
  module Zones
    class ZoneStats < Types::BaseObject
      field :zone, ::Types::Zones::Zone, null: false
      field :total_cases, Int, null: false
      field :cumulative_confirmed_cases, ::Types::LineChartType, null: false
      field :new_cases, ::Types::LineChartType, null: false
    end
  end
end
